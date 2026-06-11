# fix-git-test.ps1
# Removes the .git-test debris folder, updates .gitignore, and pushes the fix.
# Run AFTER your initial push succeeded but GitHub Pages build failed due to .git-test submodule error.
#
# Usage:
#   cd "C:\Users\h22alex\Documents\Claude\Projects\CookBook"
#   powershell -ExecutionPolicy Bypass -File .\fix-git-test.ps1

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "=== Removing .git-test debris and pushing fix ===" -ForegroundColor Cyan
Write-Host ""

Set-Location $PSScriptRoot

# Step 1: Remove the offending folder from the filesystem
if (Test-Path ".git-test") {
    Write-Host "Removing .git-test folder from disk..." -ForegroundColor Cyan
    Remove-Item -Recurse -Force ".git-test"
    Write-Host "[OK] Removed" -ForegroundColor Green
} else {
    Write-Host "[INFO] .git-test folder not present on disk (already removed)" -ForegroundColor Gray
}

# Step 2: Tell git to stop tracking it (covers case where folder was deleted but git still tracks it)
Write-Host ""
Write-Host "Removing .git-test from git index..." -ForegroundColor Cyan
git rm -r --cached --ignore-unmatch .git-test 2>&1 | Out-Null
Write-Host "[OK] Untracked" -ForegroundColor Green

# Step 3: Stage the updated .gitignore too
Write-Host ""
Write-Host "Staging changes..." -ForegroundColor Cyan
git add .gitignore
git add -A

Write-Host ""
Write-Host "Files changed:" -ForegroundColor Gray
git status --short

# Step 4: Commit
Write-Host ""
Write-Host "Committing..." -ForegroundColor Cyan
git commit -m "Remove .git-test debris and ignore it"
Write-Host "[OK] Committed" -ForegroundColor Green

# Step 5: Push
Write-Host ""
Write-Host "Pushing to GitHub..." -ForegroundColor Cyan
git push

Write-Host ""
Write-Host "=== Done! ===" -ForegroundColor Green
Write-Host ""
Write-Host "GitHub will now retry the Pages build automatically." -ForegroundColor Cyan
Write-Host "Check it at: https://github.com/alexpim11/Cookbook-Fresh/actions" -ForegroundColor Yellow
Write-Host "Wait 1-3 minutes for the build to finish, then visit:" -ForegroundColor White
Write-Host "  https://alexpim11.github.io/Cookbook-Fresh/cookbook-fresh.html" -ForegroundColor Yellow
Write-Host ""
