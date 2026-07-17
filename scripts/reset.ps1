$ErrorActionPreference = "Stop"
docker compose down -v --remove-orphans
docker rm -f local-cicd-app 2>$null
Write-Host "Jenkins data and the deployed app were removed."
