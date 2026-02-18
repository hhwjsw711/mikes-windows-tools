# all-hands/deps.ps1
# Checks that Docker Desktop is installed and the daemon is reachable.
# Docker itself is too large to auto-install; this script tells you what to do.

Write-Host "  [all-hands] Checking dependencies..." -ForegroundColor Cyan

$dockerPath = Get-Command docker -ErrorAction SilentlyContinue
if (-not $dockerPath) {
    Write-Host "    MISSING  docker  (Docker Desktop is not installed or not on PATH)" -ForegroundColor Red
    Write-Host "    Install Docker Desktop from https://www.docker.com/products/docker-desktop/" -ForegroundColor Yellow
    return
}

Write-Host "    OK  docker found at $($dockerPath.Source)" -ForegroundColor Green

$daemonOk = docker info 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "    WARNING  Docker daemon is not running. Start Docker Desktop before using all-hands." -ForegroundColor Yellow
} else {
    Write-Host "    OK  Docker daemon is running" -ForegroundColor Green
}
