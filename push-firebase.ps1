# push-firebase.ps1
# Commits and pushes the Firebase cross-device sync feature.
# Assumes you've completed Steps 1-6 of FIREBASE-SETUP.md and filled in
# firebase-config.js with your real values.
#
# Usage:
#   cd "C:\Users\h22alex\Documents\Claude\Projects\CookBook"
#   powershell -ExecutionPolicy Bypass -File .\push-firebase.ps1

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "=== Pushing Firebase cross-device sync ===" -ForegroundColor Cyan
Write-Host ""

Set-Location $PSScriptRoot

if (-not (Test-Path ".git")) {
    Write-Host "[ERROR] No .git folder. Run push-to-github.ps1 first." -ForegroundColor Red
    exit 1
}

# Warn if config still has placeholders
$config = Get-Content firebase-config.js -Raw
if ($config -match "PASTE_") {
    Write-Host "[WARN] firebase-config.js still has placeholder values." -ForegroundColor Yellow
    Write-Host "       The app will deploy but sync will not work until you fill in real values." -ForegroundColor Yellow
    Write-Host "       See FIREBASE-SETUP.md for instructions." -ForegroundColor Yellow
    Write-Host ""
    $continue = Read-Host "Continue anyway? (y/N)"
    if ($continue -ne "y") { exit 0 }
}

Write-Host "Staging changes..." -ForegroundColor Cyan
git add -A
Write-Host ""
Write-Host "Changes to commit:" -ForegroundColor Gray
git status --short
Write-Host ""

Write-Host "Committing..." -ForegroundColor Cyan
git commit -m "Add Firebase cross-device sync + remove default recipes + mobile responsive pass"
Write-Host "[OK] Committed" -ForegroundColor Green

Write-Host ""
Write-Host "Pushing to GitHub..." -ForegroundColor Cyan
git push

Write-Host ""
Write-Host "=== Done! ===" -ForegroundColor Green
Write-Host ""
Write-Host "GitHub Pages will rebuild in 1-3 minutes." -ForegroundColor Cyan
Write-Host "Watch the build at: https://github.com/alexpim11/Cookbook-Fresh/actions" -ForegroundColor Yellow
Write-Host ""
Write-Host "Once it's green:" -ForegroundColor White
Write-Host "  1. Open the app on phone 1, tap the Sync button (header), Create new household" -ForegroundColor White
Write-Host "  2. Note the 8-character code" -ForegroundColor White
Write-Host "  3. Open the app on phone 2, tap Sync, Join existing household, enter the code" -ForegroundColor White
Write-Host "  4. Watch them sync in real time!" -ForegroundColor White
Write-Host ""
