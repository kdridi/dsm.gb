#!/bin/bash
# =============================================================================
# install-hooks.sh - Installe les hooks git pour le projet
# Plateformes : Linux / macOS
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
HOOKS_DIR="$PROJECT_ROOT/.git/hooks"

echo "=== Installation des hooks git ==="

# Hook pre-commit : vérifie le build bit-perfect avant chaque commit
cat > "$HOOKS_DIR/pre-commit" << 'EOF'
#!/bin/bash
# Hook pre-commit : vérifie que le build est bit-perfect

echo "=== Vérification bit-perfect avant commit ==="

if ! make verify; then
    echo ""
    echo "[ERREUR] Le build n'est pas bit-perfect !"
    echo "Commit annulé. Corrigez les erreurs avant de committer."
    exit 1
fi

echo "[OK] Build bit-perfect validé"
EOF

chmod +x "$HOOKS_DIR/pre-commit"

echo "[OK] Hook pre-commit installé"
echo ""
echo "Chaque commit vérifiera automatiquement que le build est bit-perfect."
