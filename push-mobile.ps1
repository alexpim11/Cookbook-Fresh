# push-mobile.ps1
# Commits and pushes the mobile responsive improvements to your existing
# Cookbook-Fresh GitHub repo. Assumes the initial push has already succeeded
# (so .git already exists and the remote is set).
#
# Usage:
#   cd "C:\Users\h22alex\Documents\Claude\Projects\CookBook"
#   powershell -ExecutionPolicy Bypass -File .\push-mobile.ps1

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "=== Pushing mobile improvements ===" -ForegroundColor Cyan
Write-Host ""

Set-Location $PSScriptRoot

if (-not (Test-Path ".git")) {
    Write-Host "[ERROR] No .git folder found here." -ForegroundColor Red
    Write-Host "Run push-to-github.ps1 first to do the initial push." -ForegroundColor Yellow
    exit 1
}

# Stage every change
Write-Host "Staging changes..." -ForegroundColor Cyan
git add -A
Write-Host ""
Write-Host "Changes to be committed:" -ForegroundColor Gray
git status --short
Write-Host ""

# Commit
Write-Host "Committing..." -ForegroundColor Cyan
git commit -m "Mobile responsive pass: bottom tab nav, stacked meal plan, safe-area, typography"
Write-Host "[OK] Committed" -ForegroundColor Green

# Push
Write-Host ""
Write-Host "Pushing to GitHub..." -ForegroundColor Cyan
git push

Write-Host ""
Write-Host "=== Done! ===" -ForegroundColor Green
Write-Host ""
Write-Host "GitHub Pages will rebuild in 1-3 minutes." -ForegroundColor Cyan
Write-Host "Watch the build at: https://github.com/alexpim11/Cookbook-Fresh/actions" -ForegroundColor Yellow
Write-Host ""
Write-Host "On your phone, after the build finishes:" -ForegroundColor White
Write-Host "  1. If you've already Added to Home Screen, just open the app icon." -ForegroundColor White
Write-Host "     The service worker auto-updates on next launch." -ForegroundColor White
Write-Host "  2. If you visit the URL in Safari, pull-to-refresh once to pick up changes." -ForegroundColor White
Write-Host ""
