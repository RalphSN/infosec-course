# One-click publish this folder to GitHub and enable Pages.
# Requires: gh auth login already done in PowerShell.
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

$RepoName = "infosec-course"
$Desc     = "Information Security Risk & Protection Engineering - interactive course"

Write-Host "== Checking gh auth ==" -ForegroundColor Cyan
gh auth status
$Owner = (gh api user --jq .login).Trim()
if (-not $Owner) { throw "Cannot get GitHub login. Run: gh auth login" }
Write-Host "Account: $Owner" -ForegroundColor Green

if (-not (Test-Path ".git")) { git init -b main | Out-Null }
if (-not (git config user.name))  { git config user.name  $Owner }
if (-not (git config user.email)) { git config user.email "$Owner@users.noreply.github.com" }

git add -A
git commit -m "Add infosec course (interactive)" | Out-Null

Write-Host "== Creating repo and pushing ==" -ForegroundColor Cyan
gh repo create $RepoName --public --source=. --remote=origin --push --description $Desc

Write-Host "== Enabling GitHub Pages (main / root) ==" -ForegroundColor Cyan
try {
  gh api -X POST "repos/$Owner/$RepoName/pages" -f "source[branch]=main" -f "source[path]=/" | Out-Null
  Write-Host "Pages enabled." -ForegroundColor Green
} catch {
  Write-Host "Pages POST skipped (maybe already enabled)." -ForegroundColor Yellow
}

Start-Sleep -Seconds 4
$Url = "https://$($Owner.ToLower()).github.io/$RepoName/"
Write-Host ""
Write-Host "DONE." -ForegroundColor Green
Write-Host ("Repo : https://github.com/{0}/{1}" -f $Owner, $RepoName) -ForegroundColor Green
Write-Host ("Site : {0}  (live in ~1-2 min)" -f $Url) -ForegroundColor Green
