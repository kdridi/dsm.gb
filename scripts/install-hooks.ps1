# =============================================================================
# install-hooks.ps1 - Installe les hooks git pour le projet
# Plateforme : Windows
# =============================================================================

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
$HooksDir = Join-Path $ProjectRoot ".git\hooks"

Write-Host "=== Installation des hooks git ==="

# Hook pre-commit : vérifie le build bit-perfect avant chaque commit
$PreCommitContent = @'
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
'@

$PreCommitPath = Join-Path $HooksDir "pre-commit"
$PreCommitContent | Out-File -FilePath $PreCommitPath -Encoding ASCII -NoNewline

Write-Host "[OK] Hook pre-commit installe" -ForegroundColor Green
Write-Host ""
Write-Host "Chaque commit verifiera automatiquement que le build est bit-perfect."
