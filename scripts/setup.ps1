# =============================================================================
# setup.ps1 - Installation des dépendances pour le désassemblage Game Boy
# Plateforme : Windows
# =============================================================================

$ErrorActionPreference = "Stop"

# --- Fonctions de logging ---
function Log-Info  { param($m) Write-Host "[INFO] $m" }
function Log-Step  { param($m) Write-Host "[STEP] $m" -ForegroundColor Cyan }
function Log-Ok    { param($m) Write-Host "[OK] $m" -ForegroundColor Green }
function Log-Warn  { param($m) Write-Host "[WARN] $m" -ForegroundColor Yellow; exit 1 }
function Log-Error { param($m) Write-Host "[ERROR] $m" -ForegroundColor Red; exit 1 }
function Log-Debug { param($m) if ($env:DEBUG -eq "1") { Write-Host "[DEBUG] $m" -ForegroundColor Gray } }

# --- Variables ---
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
$ToolsDir = Join-Path $ProjectRoot "tools"
$MgbdisDir = Join-Path $ToolsDir "mgbdis"
$MgbdisScript = Join-Path $MgbdisDir "mgbdis.py"

# --- Header d'intention ---
Write-Host "============================================================================="
Write-Host "SCRIPT  : setup.ps1"
Write-Host "OBJECTIF: Verifier et installer les dependances (rgbds, mgbdis)"
Write-Host "PREREQS : Git, gestionnaire de paquets (Chocolatey ou Scoop)"
Write-Host "============================================================================="
Write-Host ""

Log-Debug "ScriptDir=$ScriptDir"
Log-Debug "ProjectRoot=$ProjectRoot"
Log-Debug "ToolsDir=$ToolsDir"

# --- Fonctions utilitaires ---
function Test-Command {
    param([string]$Command)
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

# --- Etape 1 : Verification du gestionnaire de paquets ---
Log-Step "Verification du gestionnaire de paquets..."

$PkgManager = $null

if (Test-Command "choco") {
    Log-Ok "Chocolatey est installe"
    $PkgManager = "choco"
    Log-Debug "PkgManager=choco"
} elseif (Test-Command "scoop") {
    Log-Ok "Scoop est installe"
    $PkgManager = "scoop"
    Log-Debug "PkgManager=scoop"
} else {
    Log-Error "Aucun gestionnaire de paquets detecte. Installer Chocolatey (https://chocolatey.org/install) ou Scoop (https://scoop.sh)"
}

# --- Etape 2 : Verification de Git ---
Log-Step "Verification de Git..."

if (Test-Command "git") {
    $gitVersion = git --version
    Log-Ok "Git est installe ($gitVersion)"
    Log-Debug "git path = $(Get-Command git | Select-Object -ExpandProperty Source)"
} else {
    Log-Error "Git n'est pas installe. Installer Git avant de continuer."
}

# --- Etape 3 : Verification/installation de rgbds ---
Log-Step "Verification de rgbds (rgbasm, rgblink, rgbfix)..."

if ((Test-Command "rgbasm") -and (Test-Command "rgblink") -and (Test-Command "rgbfix")) {
    $rgbVersion = rgbasm --version 2>&1 | Select-Object -First 1
    Log-Ok "rgbds est installe ($rgbVersion)"
} else {
    Log-Info "rgbds n'est pas installe. Installation en cours..."

    if ($PkgManager -eq "choco") {
        Log-Debug "Execution: choco install rgbds -y"
        choco install rgbds -y
    } elseif ($PkgManager -eq "scoop") {
        Log-Debug "Execution: scoop bucket add extras && scoop install rgbds"
        scoop bucket add extras
        scoop install rgbds
    }

    # Verification post-installation
    if ((Test-Command "rgbasm") -and (Test-Command "rgblink") -and (Test-Command "rgbfix")) {
        Log-Ok "rgbds installe avec succes"
    } else {
        Log-Error "Echec de l'installation de rgbds. Installer manuellement: https://rgbds.gbdev.io/install"
    }
}

# --- Etape 4 : Verification/installation de mgbdis ---
Log-Step "Verification de mgbdis..."

if (Test-Path $MgbdisScript) {
    Log-Ok "mgbdis est present dans $MgbdisDir"
} else {
    Log-Info "mgbdis n'est pas present. Clonage depuis GitHub..."

    Log-Debug "Creation du dossier: $ToolsDir"
    New-Item -ItemType Directory -Force -Path $ToolsDir | Out-Null

    Log-Debug "Execution: git clone https://github.com/mattcurrie/mgbdis.git $MgbdisDir"
    git clone https://github.com/mattcurrie/mgbdis.git $MgbdisDir

    # Verification post-clonage
    if (Test-Path $MgbdisScript) {
        Log-Ok "mgbdis clone avec succes dans $MgbdisDir"
    } else {
        Log-Error "Echec du clonage de mgbdis"
    }
}

# --- Resume final ---
Write-Host ""
Write-Host "============================================================================="
Write-Host "RESULTAT: SUCCES" -ForegroundColor Green
Write-Host "============================================================================="
Write-Host ""
Log-Info "Toutes les dependances sont installees"
Write-Host ""
Write-Host "Commandes disponibles :"
Write-Host "  - rgbasm, rgblink, rgbfix (rgbds)"
Write-Host "  - python $MgbdisScript"
Write-Host ""

exit 0
