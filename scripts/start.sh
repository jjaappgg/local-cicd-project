#!/usr/bin/env bash
set -euo pipefail

docker compose up -d --build
sleep 10

echo "Jenkins URL: http://localhost:8080"
echo "Initial administrator password:"
docker exec local-cicd-jenkins cat /var/jenkins_home/secrets/initialAdminPassword
