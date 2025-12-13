# ADR-0002 : Conventions de logging et gestion d'erreurs dans les scripts

## Statut
Accepté

## Contexte
Les scripts doivent être robustes, traçables et faciles à déboguer en cas de problème.

## Décision

### Règles obligatoires pour tous les scripts

#### 1. Header d'intention
Au démarrage, le script affiche :
- Son nom et sa version (si applicable)
- Son intention/objectif en une phrase
- Les prérequis attendus

#### 2. Logging par étape
Avant chaque étape :
- Afficher l'intention de l'étape (ce qu'on va faire)
- Afficher le résultat (succès ou échec avec détails)

#### 3. Mode debug
- Variable d'environnement `DEBUG=1` pour activer les logs verbeux
- En mode debug : afficher les commandes exécutées

#### 4. Gestion des erreurs stricte
- S'arrêter à la première erreur (pas de continuation silencieuse)
- S'arrêter au premier warning critique
- Afficher clairement l'erreur rencontrée avec contexte

#### 5. Sortie standardisée
- Code de sortie 0 = succès
- Code de sortie != 0 = échec
- Message final récapitulatif (succès ou échec)

### Implémentation

#### Bash (.sh)
```bash
set -euo pipefail  # Arrêt sur erreur, variable non définie, pipe fail

log_info()  { echo "[INFO] $*"; }
log_step()  { echo "[STEP] $*"; }
log_ok()    { echo "[OK] $*"; }
log_warn()  { echo "[WARN] $*"; }
log_error() { echo "[ERROR] $*" >&2; }
log_debug() { [ "${DEBUG:-0}" = "1" ] && echo "[DEBUG] $*" || true; }
```

#### PowerShell (.ps1)
```powershell
$ErrorActionPreference = "Stop"

function Log-Info  { param($m) Write-Host "[INFO] $m" }
function Log-Step  { param($m) Write-Host "[STEP] $m" -ForegroundColor Cyan }
function Log-Ok    { param($m) Write-Host "[OK] $m" -ForegroundColor Green }
function Log-Warn  { param($m) Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Log-Error { param($m) Write-Host "[ERROR] $m" -ForegroundColor Red }
function Log-Debug { param($m) if ($env:DEBUG -eq "1") { Write-Host "[DEBUG] $m" -ForegroundColor Gray } }
```

## Conséquences
- Scripts plus verbeux mais traçables
- Debugging facilité
- Comportement prévisible et cohérent
