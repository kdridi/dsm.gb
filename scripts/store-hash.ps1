# =============================================================================
# store-hash.ps1 - Calcule et stocke les hash de référence de la ROM originale
# Plateforme : Windows (PowerShell)
# =============================================================================

$ErrorActionPreference = "Stop"

# --- Fonctions de logging ---
function Log-Info  { param($msg) Write-Host "[INFO] $msg" }
function Log-Step  { param($msg) Write-Host "[STEP] $msg" -ForegroundColor Cyan }
function Log-Ok    { param($msg) Write-Host "[OK] $msg" -ForegroundColor Green }
function Log-Warn  { param($msg) Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Log-Error { param($msg) Write-Host "[ERROR] $msg" -ForegroundColor Red; exit 1 }
function Log-Debug { param($msg) if ($env:DEBUG -eq "1") { Write-Host "[DEBUG] $msg" -ForegroundColor Gray } }

# --- Variables ---
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
$RomFile = Join-Path $ProjectRoot "rom.gb"
$Sha256File = Join-Path $ProjectRoot "checksum.sha256"
$Md5File = Join-Path $ProjectRoot "checksum.md5"

# --- Header d'intention ---
Write-Host "============================================================================="
Write-Host "SCRIPT  : store-hash.ps1"
Write-Host "OBJECTIF: Calculer et stocker les hash SHA256/MD5 de la ROM originale"
Write-Host "PREREQS : rom.gb present a la racine du projet"
Write-Host "============================================================================="
Write-Host ""

Log-Debug "ScriptDir=$ScriptDir"
Log-Debug "ProjectRoot=$ProjectRoot"
Log-Debug "RomFile=$RomFile"

# --- Etape 1 : Verification de rom.gb ---
Log-Step "Verification de la presence de rom.gb..."

if (-not (Test-Path $RomFile)) {
    Log-Error "rom.gb non trouve dans $ProjectRoot"
}

$RomSize = (Get-Item $RomFile).Length
Log-Ok "rom.gb trouve ($RomSize octets)"
Log-Debug "RomSize=$RomSize"

# --- Etape 2 : Calcul du hash SHA256 ---
Log-Step "Calcul du hash SHA256..."

$Sha256Hash = (Get-FileHash -Path $RomFile -Algorithm SHA256).Hash.ToLower()
Log-Ok "SHA256: $Sha256Hash"
Log-Debug "SHA256=$Sha256Hash"

# --- Etape 3 : Calcul du hash MD5 ---
Log-Step "Calcul du hash MD5..."

$Md5Hash = (Get-FileHash -Path $RomFile -Algorithm MD5).Hash.ToLower()
Log-Ok "MD5: $Md5Hash"
Log-Debug "MD5=$Md5Hash"

# --- Etape 4 : Stockage des hash ---
Log-Step "Stockage des hash de reference..."

$Sha256Hash | Out-File -FilePath $Sha256File -Encoding ASCII -NoNewline
Log-Debug "Ecrit: $Sha256File"

$Md5Hash | Out-File -FilePath $Md5File -Encoding ASCII -NoNewline
Log-Debug "Ecrit: $Md5File"

Log-Ok "Hash stockes dans checksum.sha256 et checksum.md5"

# --- Resume final ---
Write-Host ""
Write-Host "============================================================================="
Write-Host "RESULTAT: SUCCES"
Write-Host "============================================================================="
Write-Host ""
Log-Info "Hash de reference enregistres :"
Write-Host "  SHA256: $Sha256Hash"
Write-Host "  MD5:    $Md5Hash"
Write-Host ""
Log-Info "Fichiers crees :"
Write-Host "  - $Sha256File"
Write-Host "  - $Md5File"
Write-Host ""

exit 0
