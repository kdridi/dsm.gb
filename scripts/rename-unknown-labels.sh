#!/usr/bin/env bash
#
# rename-unknown-labels.sh
#
# Renomme intelligemment les labels UnknownCode_00[23]_XXXX selon leur contexte :
# - PaddingZone_* : nop/rst $38/ld b,b répétés
# - DataZone_* : patterns data suspects (daa, db, etc.)
# - DispatchTableEntry_* : destinations de jump/rst
# - SpriteAnimation_* : code animation sprites (bank 002)
# - Audio_* : code audio (bank 003)
#

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables globales
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SRC_DIR="${REPO_ROOT}/src"
SUBSTITUTIONS_FILE="${REPO_ROOT}/.rename-substitutions.txt"
DRY_RUN=0

# Compteurs
TOTAL_LABELS=0
PADDING_COUNT=0
DATA_COUNT=0
DISPATCH_COUNT=0
SPRITE_ANIM_COUNT=0
AUDIO_COUNT=0

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Renommage des labels UnknownCode_00[23]${NC}"
echo -e "${BLUE}========================================${NC}"

# Parse options
while getopts "dn" opt; do
    case $opt in
        d) DRY_RUN=1 ;;
        n) DRY_RUN=1 ;;
        *) echo "Usage: $0 [-d|-n] (dry-run mode)" ; exit 1 ;;
    esac
done

if [ $DRY_RUN -eq 1 ]; then
    echo -e "${YELLOW}[DRY-RUN MODE] Aucune modification ne sera appliquée${NC}"
fi

# Nettoyer le fichier de substitutions
> "$SUBSTITUTIONS_FILE"

#
# Fonction : analyse le contexte d'un label et détermine le type
#
# Arguments:
#   $1 = fichier source
#   $2 = numéro de ligne du label
#   $3 = nom du label (ex: UnknownCode_002_48d6)
#
# Retour: echo le nouveau nom du label
#
classify_label() {
    local file="$1"
    local line_num="$2"
    local label="$3"
    local bank_num
    local addr

    # Extraire bank et adresse du label
    bank_num=$(echo "$label" | sed -E 's/UnknownCode_00([23])_[0-9A-Fa-f]+/\1/')
    addr=$(echo "$label" | sed -E 's/UnknownCode_00[23]_([0-9A-Fa-f]+)/\1/')

    # Extraire 15 lignes de contexte après le label
    local context
    context=$(sed -n "${line_num},$((line_num + 15))p" "$file")

    # Pattern 1: PADDING ZONE
    # - 3+ nop consécutifs
    # - 3+ rst $38 consécutifs
    # - 6+ ld b,b consécutifs
    local nop_count
    local rst38_count
    local ldb_count

    nop_count=$(echo "$context" | grep -c "^\s*nop\s*$" || true)
    rst38_count=$(echo "$context" | grep -c "^\s*rst \$38\s*$" || true)
    ldb_count=$(echo "$context" | grep -c "^\s*ld b, b\s*$" || true)

    if [ "$nop_count" -ge 3 ] || [ "$rst38_count" -ge 3 ] || [ "$ldb_count" -ge 6 ]; then
        PADDING_COUNT=$((PADDING_COUNT + 1))
        echo "PaddingZone_00${bank_num}_${addr}"
        return
    fi

    # Pattern 2: DATA ZONE
    # - 3+ lignes avec "daa" consécutives
    # - 5+ lignes avec "db " (directive data)
    # - Pattern "ld b, b" répété 4+ fois (mais moins que padding)
    local daa_count
    local db_count

    daa_count=$(echo "$context" | grep -c "^\s*daa\s*$" || true)
    db_count=$(echo "$context" | grep -c "^\s*db " || true)

    if [ "$daa_count" -ge 3 ] || [ "$db_count" -ge 5 ] || [ "$ldb_count" -ge 4 ]; then
        DATA_COUNT=$((DATA_COUNT + 1))
        echo "DataZone_00${bank_num}_${addr}"
        return
    fi

    # Pattern 3: DISPATCH TABLE ENTRY
    # - Présence de "jr " ou "jp " dans les 5 premières lignes
    # - OU label précédé d'un "rst $28" (dispatch via jump table)
    # - OU pattern de switch/case (cp + jr z/nz)
    local has_jump
    local has_dispatch
    local has_switch

    has_jump=$(echo "$context" | head -5 | grep -E "^\s*(jr |jp )" | wc -l || true)
    has_switch=$(echo "$context" | head -8 | grep -E "^\s*cp " | wc -l || true)

    # Vérifier si précédé par rst $28 (dans les 10 lignes avant)
    local before_context
    local before_line=$((line_num - 10))
    [ $before_line -lt 1 ] && before_line=1
    before_context=$(sed -n "${before_line},$((line_num - 1))p" "$file")
    has_dispatch=$(echo "$before_context" | grep -c "rst \$28" || true)

    if [ "$has_jump" -gt 0 ] || [ "$has_dispatch" -gt 0 ] || [ "$has_switch" -ge 2 ]; then
        DISPATCH_COUNT=$((DISPATCH_COUNT + 1))
        echo "DispatchTableEntry_00${bank_num}_${addr}"
        return
    fi

    # Pattern 4 & 5: Distinction BANK_002 vs BANK_003
    if [ "$bank_num" = "2" ]; then
        # BANK_002 : SPRITE ANIMATION
        # Heuristiques : ld [hl], ops sur OAM, coord X/Y
        local has_sprite_ops
        has_sprite_ops=$(echo "$context" | grep -E "(ld \[hl\]|OAM|coord|sprite)" -i | wc -l || true)

        if [ "$has_sprite_ops" -gt 0 ]; then
            SPRITE_ANIM_COUNT=$((SPRITE_ANIM_COUNT + 1))
            echo "SpriteAnimation_00${bank_num}_${addr}"
            return
        fi
    else
        # BANK_003 : AUDIO
        # Heuristiques : NR*, audio, sound, channel
        local has_audio_ops
        has_audio_ops=$(echo "$context" | grep -E "(rNR[0-9]|ldh \[rNR|audio|sound|channel)" -i | wc -l || true)

        if [ "$has_audio_ops" -gt 0 ]; then
            AUDIO_COUNT=$((AUDIO_COUNT + 1))
            echo "Audio_00${bank_num}_${addr}"
            return
        fi
    fi

    # Fallback: garder le label UnknownCode (sera traité dans une future phase)
    echo "$label"
}

#
# Étape 1 : Scanner les fichiers et construire les substitutions
#
echo ""
echo -e "${BLUE}[1/4] Analyse des labels...${NC}"

for bank_file in "${SRC_DIR}/bank_002.asm" "${SRC_DIR}/bank_003.asm"; do
    if [ ! -f "$bank_file" ]; then
        echo -e "${RED}Erreur : fichier $bank_file introuvable${NC}"
        exit 1
    fi

    echo -e "${YELLOW}Analyse : $(basename "$bank_file")${NC}"

    # Extraire tous les labels UnknownCode_00[23]
    while IFS=: read -r line_num label_line; do
        # Extraire le nom du label (sans le ':')
        label=$(echo "$label_line" | sed -E 's/^(UnknownCode_00[23]_[0-9A-Fa-f]+):.*$/\1/')

        TOTAL_LABELS=$((TOTAL_LABELS + 1))

        # Classifier le label
        new_label=$(classify_label "$bank_file" "$line_num" "$label")

        # Si changement, ajouter à la liste de substitutions
        if [ "$new_label" != "$label" ]; then
            echo "${label}|${new_label}" >> "$SUBSTITUTIONS_FILE"
            echo "  ${label} -> ${new_label}"
        fi
    done < <(grep -n "^UnknownCode_00[23]_[0-9A-Fa-f]\+:" "$bank_file" || true)
done

#
# Étape 2 : Statistiques
#
echo ""
echo -e "${BLUE}[2/4] Statistiques${NC}"
echo "  Total labels analysés : $TOTAL_LABELS"
echo "  - PaddingZone : $PADDING_COUNT"
echo "  - DataZone : $DATA_COUNT"
echo "  - DispatchTableEntry : $DISPATCH_COUNT"
echo "  - SpriteAnimation : $SPRITE_ANIM_COUNT"
echo "  - Audio : $AUDIO_COUNT"

RENAMED_COUNT=$((PADDING_COUNT + DATA_COUNT + DISPATCH_COUNT + SPRITE_ANIM_COUNT + AUDIO_COUNT))
UNCHANGED_COUNT=$((TOTAL_LABELS - RENAMED_COUNT))

echo ""
echo "  Labels renommés : ${GREEN}${RENAMED_COUNT}${NC}"
echo "  Labels inchangés : ${YELLOW}${UNCHANGED_COUNT}${NC}"

if [ $RENAMED_COUNT -eq 0 ]; then
    echo -e "${YELLOW}Aucun label à renommer. Fin.${NC}"
    rm -f "$SUBSTITUTIONS_FILE"
    exit 0
fi

#
# Étape 3 : Appliquer les substitutions
#
if [ $DRY_RUN -eq 1 ]; then
    echo ""
    echo -e "${YELLOW}[3/4] DRY-RUN : Substitutions NON appliquées${NC}"
    echo "Fichier de substitutions : $SUBSTITUTIONS_FILE"
    exit 0
fi

echo ""
echo -e "${BLUE}[3/4] Application des substitutions...${NC}"

# Pour chaque substitution, on applique sed sur TOUS les fichiers .asm
# (car les labels peuvent être référencés ailleurs)
while IFS='|' read -r old_label new_label; do
    echo "  Renommage : ${old_label} -> ${new_label}"

    # Sed sur tous les fichiers .asm du src/
    find "${SRC_DIR}" -name "*.asm" -type f -exec sed -i '' "s/${old_label}/${new_label}/g" {} +
done < "$SUBSTITUTIONS_FILE"

#
# Étape 4 : Vérification
#
echo ""
echo -e "${BLUE}[4/4] Vérification du hash...${NC}"

cd "$REPO_ROOT"
if make verify > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Hash vérifié : binaire identique${NC}"
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}Renommage terminé avec succès !${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "Commandes suggérées :"
    echo "  git diff src/         # Vérifier les changements"
    echo "  git add src/"
    echo "  git commit -m '[ROADMAP-XXX] Renommer ${RENAMED_COUNT} labels UnknownCode_00[23]_XXXX'"

    # Nettoyer le fichier de substitutions
    rm -f "$SUBSTITUTIONS_FILE"
else
    echo -e "${RED}✗ ERREUR : Le hash ne correspond plus !${NC}"
    echo -e "${YELLOW}Restauration via git...${NC}"
    git checkout -- src/
    rm -f "$SUBSTITUTIONS_FILE"
    exit 1
fi
