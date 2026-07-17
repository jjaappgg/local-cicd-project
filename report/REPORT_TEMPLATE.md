# Local Automated Deployment Pipeline Report

## Group Members

- Javier Perez
- [Add other group members, or delete this line]

## GitHub Repository

[Paste the GitHub repository URL here]

## Project Objective

This project implements a local automated deployment pipeline that integrates Git/GitHub, Jenkins, Terraform, and Docker. GitHub stores the source and pipeline configuration. Jenkins retrieves the repository, validates the project, builds and tests the Docker image, and executes Terraform. Terraform uses the Docker provider to deploy the locally built image as a container. Docker Desktop provides the local runtime for both Jenkins and the final application.

## Architecture and Local Setup

Jenkins runs inside the `local-cicd-jenkins` Docker container. The host Docker socket, `/var/run/docker.sock`, is mounted into that container. Jenkins has the Docker command-line client and Terraform installed, so both tools communicate with the Docker Desktop daemon through the mounted socket. This allows Jenkins to build an image and allows Terraform's Docker provider to create the final container in the host's Docker environment.

The deployed application is a small Flask web service. Jenkins tags each image with its build number and also updates the `latest` tag. Terraform reads the build-number tag from the local Docker daemon, replaces the previous application container when necessary, and exposes the application on host port 5000.

## Requirement Verification

### 1. Git/GitHub

The GitHub repository contains:

- Flask application source under `app/`
- `Dockerfile`
- `Jenkinsfile`
- Terraform `.tf` files under `terraform/`
- Jenkins container setup under `jenkins/`
- `docker-compose.yml`

### 2. Automated CI Trigger

The Jenkinsfile defines SCM polling with `pollSCM('H/2 * * * *')`. After the pipeline job was run once, Jenkins checked the GitHub repository approximately every two minutes. A new commit caused Jenkins to execute the pipeline automatically.

**Screenshot:** Paste the Jenkins build page showing “Started by an SCM change.”

### 3. Jenkins — Builder

The Jenkins pipeline performs the following stages:

1. Checkout
2. Validate Files
3. Build Docker Image
4. Test Docker Image
5. Deploy with Terraform
6. Verify Deployment

The test stage starts a temporary container from the newly built image and checks its `/health` endpoint before deployment. The deployment stage runs `terraform apply -auto-approve` with the new image tag.

**Screenshot:** Paste the successful Jenkins stage view or console output here.

### 4. Terraform — Deployer

Terraform uses the `kreuzwerker/docker` provider. The `docker_image` data source reads the image that Jenkins built locally. The `docker_container` resource deploys that image as `local-cicd-app` and publishes container port 5000 to host port 5000.

**Screenshot:** Paste the Terraform apply output from Jenkins here.

### 5. Docker — Runtime

Docker Desktop hosts both:

- `local-cicd-jenkins`, available at `http://localhost:8080`
- `local-cicd-app`, available at `http://localhost:5000`

**Screenshot:** Paste a browser screenshot of the deployed application here.

**Optional screenshot:** Paste `docker ps` showing both containers here.

## Final Result

The complete pipeline successfully detected a GitHub change, started Jenkins automatically, built and tested a new Docker image, used Terraform to deploy it, and served the updated application through Docker at `http://localhost:5000`.
