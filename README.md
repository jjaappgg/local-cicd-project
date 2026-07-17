# Local Automated Deployment Pipeline

This project implements the full assignment pipeline:

**GitHub → Jenkins → Docker build → Terraform apply → Docker container**

It includes all five grading items:

- Git/GitHub stores the application, Dockerfile, Jenkinsfile, and Terraform files.
- Jenkins uses `pollSCM` every two minutes to detect repository updates.
- Jenkins checks out the repository, validates files, builds/tests the image, and runs Terraform.
- Terraform uses the `kreuzwerker/docker` provider and deploys the locally built image.
- Docker hosts both Jenkins and the final Flask application.

## Architecture

```text
GitHub repository
       |
       | SCM polling every ~2 minutes
       v
Jenkins container
       |
       | Docker CLI through /var/run/docker.sock
       v
Host Docker daemon
       |
       +--> Builds local-cicd-app:<build-number>
       |
       +--> Terraform Docker provider
                  |
                  v
          local-cicd-app container
          http://localhost:5000
```

## Prerequisites

1. Docker Desktop, configured to use Linux containers.
2. Git.
3. A GitHub account and a repository containing this project.

No separate Jenkins or Terraform installation is required on the host. The custom Jenkins image contains Git, Python, Docker CLI, curl, and Terraform.

## 1. Put the project on GitHub

Create an empty GitHub repository, then run these commands from this project's root directory:

```powershell
git init
git add .
git commit -m "Initial local CI/CD pipeline"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPOSITORY.git
git push -u origin main
```

Do not use the placeholder URL literally. Replace it with your repository URL.

## 2. Start Jenkins

On Windows PowerShell:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\start.ps1
```

Or manually:

```powershell
docker compose up -d --build
docker exec local-cicd-jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

Open `http://localhost:8080`, paste the displayed password, and complete the setup wizard. Select **Install suggested plugins**. The image also preinstalls the pipeline, Git, credentials-binding, and timestamps plugins required by this project.

## 3. Create the Jenkins Pipeline job

1. Select **New Item**.
2. Enter `local-cicd-pipeline`.
3. Select **Pipeline**, then **OK**.
4. Under **Pipeline**, choose **Pipeline script from SCM**.
5. Set **SCM** to **Git**.
6. Enter your GitHub repository URL.
7. For a public repository, credentials can remain empty. For a private repository, add a GitHub personal access token as a Jenkins credential.
8. Set **Branch Specifier** to `*/main`.
9. Set **Script Path** to `Jenkinsfile`.
10. Save and select **Build Now** once.

The `Jenkinsfile` contains:

```groovy
triggers {
    pollSCM('H/2 * * * *')
}
```

After the first run, Jenkins checks GitHub approximately every two minutes and starts a build when it detects a new commit.

## 4. Verify the finished deployment

A successful pipeline ends with these checks:

```text
Docker image built
Application image health test passed
Terraform apply completed
local-cicd-app container is running
GET /health returned {"status":"ok"}
```

Open:

- Application: `http://localhost:5000`
- Health check: `http://localhost:5000/health`
- Jenkins: `http://localhost:8080`

Useful commands:

```powershell
docker ps
docker images local-cicd-app
docker logs local-cicd-app
docker inspect local-cicd-app
```

## 5. Demonstrate the automatic trigger

Change the heading in `app/app.py`, then commit and push:

```powershell
git add app/app.py
git commit -m "Demonstrate automatic Jenkins trigger"
git push
```

Wait about two minutes. Jenkins should create a new build automatically. Take a screenshot of the build history showing the new build and its **Started by an SCM change** cause.

## Required screenshots

Save screenshots in `report/screenshots/` or paste them directly into the submitted report:

1. Jenkins build history with at least one successful build.
2. Build page showing **Started by an SCM change**.
3. Pipeline stage view or console output showing Docker build and Terraform apply.
4. Browser showing `http://localhost:5000` and the “Deployment successful!” page.
5. Optional supporting screenshot of `docker ps` showing both Jenkins and `local-cicd-app`.

## How Jenkins reaches Docker

The Jenkins service mounts the host Docker socket:

```yaml
- /var/run/docker.sock:/var/run/docker.sock
```

The Docker CLI and Terraform process run inside Jenkins, but their API calls go through this socket to Docker Desktop's daemon. Therefore, images and containers created by Jenkins appear in the same local Docker environment as containers started from the host terminal.

This is convenient for a classroom project but grants the Jenkins container powerful control over the Docker host. Do not expose this Jenkins instance to untrusted users or the public internet.

## Troubleshooting

### Port 8080 or 5000 is already used

Change the left side of the Jenkins mapping in `docker-compose.yml`, or change `APPLICATION_PORT` in the `Jenkinsfile` and the Terraform `host_port` variable.

### Docker permission error

Confirm Docker Desktop is running and configured for Linux containers. Then recreate Jenkins:

```powershell
docker compose down
docker compose up -d --build
```

### Repository polling does not trigger

Run the job manually once after saving it. Confirm the job is configured from SCM and the branch is `*/main`. Push a genuinely new commit and wait at least two minutes. On the job page, use **Git Polling Log** to inspect the polling result.

### Terraform reports that the container name already exists

Remove the unmanaged old container and rebuild:

```powershell
docker rm -f local-cicd-app
```

### Reset everything

```powershell
.\scripts\reset.ps1
```

This deletes the Jenkins volume, so Jenkins setup and job configuration will need to be repeated.
# automated trigger test
