#!/bin/bash
# =============================================================================
# setup.sh - Installation des dépendances pour le projet Game Boy ASM
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

# --- Header d'intention ---
echo "============================================================================="
echo "SCRIPT  : setup.sh"
echo "OBJECTIF: Vérifier et installer les dépendances (rgbds)"
echo "PREREQS : Gestionnaire de paquets (brew/apt/pacman/dnf)"
echo "============================================================================="
echo ""

log_debug "SCRIPT_DIR=$SCRIPT_DIR"
log_debug "PROJECT_ROOT=$PROJECT_ROOT"

# --- Fonctions utilitaires ---
check_command() {
    command -v "$1" >/dev/null 2>&1
}

# --- Étape 1 : Détection de l'OS ---
log_step "Détection du système d'exploitation..."

OS="$(uname -s)"
case "$OS" in
    Linux*)  OS_TYPE="linux";;
    Darwin*) OS_TYPE="macos";;
    *)       log_error "OS non supporté: $OS";;
esac

log_ok "OS détecté: $OS_TYPE"
log_debug "uname -s = $OS"

# --- Étape 2 : Vérification du gestionnaire de paquets ---
log_step "Vérification du gestionnaire de paquets..."

PKG_INSTALL=""

if [ "$OS_TYPE" = "macos" ]; then
    if ! check_command brew; then
        log_error "Homebrew n'est pas installé. Installer avec : /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    fi
    log_ok "Homebrew est installé"
    PKG_INSTALL="brew install"
    log_debug "PKG_INSTALL=$PKG_INSTALL"

elif [ "$OS_TYPE" = "linux" ]; then
    if check_command apt-get; then
        PKG_INSTALL="sudo apt-get install -y"
    elif check_command pacman; then
        PKG_INSTALL="sudo pacman -S --noconfirm"
    elif check_command dnf; then
        PKG_INSTALL="sudo dnf install -y"
    else
        log_warn "Aucun gestionnaire de paquets détecté (apt/pacman/dnf). Installation manuelle requise."
    fi
    log_ok "Gestionnaire de paquets détecté"
    log_debug "PKG_INSTALL=$PKG_INSTALL"
fi

# --- Étape 3 : Vérification/installation de rgbds ---
log_step "Vérification de rgbds (rgbasm, rgblink, rgbfix)..."

if check_command rgbasm && check_command rgblink && check_command rgbfix; then
    log_ok "rgbds est installé ($(rgbasm --version 2>&1 | head -1))"
else
    log_info "rgbds n'est pas installé. Installation en cours..."
    log_debug "Exécution: $PKG_INSTALL rgbds"

    if [ -z "$PKG_INSTALL" ]; then
        log_error "Impossible d'installer rgbds automatiquement. Installer manuellement: https://rgbds.gbdev.io/install"
    fi

    $PKG_INSTALL rgbds

    if check_command rgbasm && check_command rgblink && check_command rgbfix; then
        log_ok "rgbds installé avec succès"
    else
        log_error "Échec de l'installation de rgbds"
    fi
fi

# --- Résumé final ---
echo ""
echo "============================================================================="
echo "RESULTAT: SUCCES"
echo "============================================================================="
echo ""
log_info "Toutes les dépendances sont installées"
echo ""
echo "Commandes disponibles :"
echo "  - rgbasm, rgblink, rgbfix (rgbds)"
echo ""

exit 0
