$ErrorActionPreference = "Stop"

Write-Host "Starting Jenkins..."
docker compose up -d --build

Write-Host "Waiting for Jenkins to create its initial password..."
Start-Sleep -Seconds 10

Write-Host ""
Write-Host "Jenkins URL: http://localhost:8080"
Write-Host "Initial administrator password:"
docker exec local-cicd-jenkins cat /var/jenkins_home/secrets/initialAdminPassword
