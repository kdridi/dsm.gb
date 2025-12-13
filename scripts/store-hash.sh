#!/bin/bash
# =============================================================================
# store-hash.sh - Calcule et stocke les hash de référence de la ROM originale
# Plateformes : Linux / macOS
# =============================================================================

set -euo pipefail

# --- Fonctions de logging ---
log_info()  { echo "[INFO] $*"; }
log_step()  { echo "[STEP] $*"; }
log_ok()    { echo "[OK] $*"; }
log_warn()  { echo "[WARN] $*" >&2; }
log_error() { echo "[ERROR] $*" >&2; exit 1; }
log_debug() { [ "${DEBUG:-0}" = "1" ] && echo "[DEBUG] $*" || true; }

# --- Variables ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ROM_FILE="$PROJECT_ROOT/rom.gb"
SHA256_FILE="$PROJECT_ROOT/checksum.sha256"
MD5_FILE="$PROJECT_ROOT/checksum.md5"

# --- Header d'intention ---
echo "============================================================================="
echo "SCRIPT  : store-hash.sh"
echo "OBJECTIF: Calculer et stocker les hash SHA256/MD5 de la ROM originale"
echo "PREREQS : rom.gb présent à la racine du projet"
echo "============================================================================="
echo ""

log_debug "SCRIPT_DIR=$SCRIPT_DIR"
log_debug "PROJECT_ROOT=$PROJECT_ROOT"
log_debug "ROM_FILE=$ROM_FILE"

# --- Étape 1 : Vérification de rom.gb ---
log_step "Vérification de la présence de rom.gb..."

if [ ! -f "$ROM_FILE" ]; then
    log_error "rom.gb non trouvé dans $PROJECT_ROOT"
fi

ROM_SIZE=$(wc -c < "$ROM_FILE" | tr -d ' ')
log_ok "rom.gb trouvé ($ROM_SIZE octets)"
log_debug "ROM_SIZE=$ROM_SIZE"

# --- Étape 2 : Calcul du hash SHA256 ---
log_step "Calcul du hash SHA256..."

# macOS utilise shasum, Linux peut utiliser sha256sum
if command -v shasum >/dev/null 2>&1; then
    SHA256=$(shasum -a 256 "$ROM_FILE" | cut -d' ' -f1)
elif command -v sha256sum >/dev/null 2>&1; then
    SHA256=$(sha256sum "$ROM_FILE" | cut -d' ' -f1)
else
    log_error "Aucun outil SHA256 trouvé (shasum ou sha256sum requis)"
fi

log_ok "SHA256: $SHA256"
log_debug "SHA256=$SHA256"

# --- Étape 3 : Calcul du hash MD5 ---
log_step "Calcul du hash MD5..."

# macOS utilise md5, Linux utilise md5sum
if command -v md5 >/dev/null 2>&1; then
    MD5=$(md5 -q "$ROM_FILE")
elif command -v md5sum >/dev/null 2>&1; then
    MD5=$(md5sum "$ROM_FILE" | cut -d' ' -f1)
else
    log_error "Aucun outil MD5 trouvé (md5 ou md5sum requis)"
fi

log_ok "MD5: $MD5"
log_debug "MD5=$MD5"

# --- Étape 4 : Stockage des hash ---
log_step "Stockage des hash de référence..."

echo "$SHA256" > "$SHA256_FILE"
log_debug "Écrit: $SHA256_FILE"

echo "$MD5" > "$MD5_FILE"
log_debug "Écrit: $MD5_FILE"

log_ok "Hash stockés dans checksum.sha256 et checksum.md5"

# --- Résumé final ---
echo ""
echo "============================================================================="
echo "RESULTAT: SUCCES"
echo "============================================================================="
echo ""
log_info "Hash de référence enregistrés :"
echo "  SHA256: $SHA256"
echo "  MD5:    $MD5"
echo ""
log_info "Fichiers créés :"
echo "  - $SHA256_FILE"
echo "  - $MD5_FILE"
echo ""

exit 0
