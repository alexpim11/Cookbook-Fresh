# push-to-github.ps1
# Pushes the PWA files in this folder to https://github.com/alexpim11/Cookbook-Fresh.git
#
# How to run:
#   1. Open PowerShell (Start menu, type "PowerShell", press Enter)
#   2. cd "C:\Users\h22alex\Documents\Claude\Projects\CookBook"
#   3. powershell -ExecutionPolicy Bypass -File .\push-to-github.ps1
#
# When git push runs at the end, a browser window will pop up asking you to sign in to GitHub.
# Authorize "Git Credential Manager" and you are done. Future pushes will not ask again.

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "=== Cookbook-Fresh git push helper ===" -ForegroundColor Cyan
Write-Host ""

# Check git is installed
try {
    $gitVersion = git --version
    Write-Host "[OK] Git found: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] git is not installed on your system." -ForegroundColor Red
    Write-Host "Install Git for Windows from https://git-scm.com/download/win then re-run this script." -ForegroundColor Yellow
    exit 1
}

# Move to the script's own folder so paths work regardless of where it was launched
Set-Location $PSScriptRoot
Write-Host "Working in: $PSScriptRoot" -ForegroundColor Gray

# Step 1: Clean up any broken .git folder from previous attempts
if (Test-Path ".git") {
    Write-Host ""
    Write-Host "Removing previous .git folder (likely broken from sandbox attempt)..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force ".git"
    Write-Host "[OK] Removed" -ForegroundColor Green
}

# Step 2: Initialize fresh repo
Write-Host ""
Write-Host "Initializing git repo..." -ForegroundColor Cyan
git init -b main
git config user.email "h22alex@gmail.com"
git config user.name "Alex"
git config core.autocrlf true
Write-Host "[OK] Initialized with main branch" -ForegroundColor Green

# Step 3: Stage files (the .gitignore already excludes my-cookbook-ios/)
Write-Host ""
Write-Host "Staging PWA files..." -ForegroundColor Cyan
git add -A

Write-Host ""
Write-Host "Files being committed:" -ForegroundColor Gray
git status --short
Write-Host ""

# Step 4: Commit
Write-Host "Creating initial commit..." -ForegroundColor Cyan
git commit -m "Initial PWA: cookbook app + manifest + service worker + icons"
Write-Host "[OK] Committed" -ForegroundColor Green

# Step 5: Add remote
Write-Host ""
Write-Host "Adding GitHub remote..." -ForegroundColor Cyan
git remote add origin https://github.com/alexpim11/Cookbook-Fresh.git
Write-Host "[OK] Remote 'origin' set to alexpim11/Cookbook-Fresh" -ForegroundColor Green

# Step 6: Push (this will trigger the auth flow)
Write-Host ""
Write-Host "Pushing to GitHub..." -ForegroundColor Cyan
Write-Host "(A browser window will open for GitHub sign-in. That is normal.)" -ForegroundColor Yellow
Write-Host ""

git push -u origin main

Write-Host ""
Write-Host "=== Done! ===" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Go to https://github.com/alexpim11/Cookbook-Fresh to confirm files uploaded" -ForegroundColor White
Write-Host "  2. In the repo, click Settings, then Pages" -ForegroundColor White
Write-Host "  3. Under Source, pick 'Deploy from a branch' -> main -> / (root) -> Save" -ForegroundColor White
Write-Host "  4. Wait 1-2 minutes, then visit:" -ForegroundColor White
Write-Host "       https://alexpim11.github.io/Cookbook-Fresh/cookbook-fresh.html" -ForegroundColor Yellow
Write-Host "  5. Open that URL in Safari on your iPhone, tap Share, then Add to Home Screen" -ForegroundColor White
Write-Host ""
