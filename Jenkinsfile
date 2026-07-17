pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    // Check GitHub for new commits approximately every two minutes.
    triggers {
        pollSCM('H/2 * * * *')
    }

    environment {
        IMAGE_REPOSITORY = 'local-cicd-app'
        CONTAINER_NAME    = 'local-cicd-app'
        APPLICATION_PORT  = '5000'
        TF_IN_AUTOMATION  = 'true'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Validate Files') {
            steps {
                sh '''
                    set -eux

                    test -f Dockerfile
                    test -f Jenkinsfile
                    test -f terraform/main.tf

                    python3 -m py_compile app/app.py

                    terraform -chdir=terraform fmt -check
                    terraform -chdir=terraform init -input=false
                    terraform -chdir=terraform validate
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    set -eux

                    docker build \
                      --label ci.build.number=${BUILD_NUMBER} \
                      --label ci.git.commit=${GIT_COMMIT} \
                      -t ${IMAGE_REPOSITORY}:${BUILD_NUMBER} \
                      -t ${IMAGE_REPOSITORY}:latest \
                      .
                '''
            }
        }

        stage('Test Docker Image') {
            steps {
                sh '''
                    set -eux

                    TEST_CONTAINER="${CONTAINER_NAME}-test-${BUILD_NUMBER}"

                    docker rm -f "$TEST_CONTAINER" >/dev/null 2>&1 || true

                    docker run -d \
                      --rm \
                      --name "$TEST_CONTAINER" \
                      -p 15000:5000 \
                      ${IMAGE_REPOSITORY}:${BUILD_NUMBER}

                    trap 'docker rm -f "$TEST_CONTAINER" >/dev/null 2>&1 || true' EXIT

                    for attempt in $(seq 1 15); do
                        if curl --fail --silent \
                          http://host.docker.internal:15000/health \
                          | grep -q '"status":"ok"'; then

                            echo "Application health check passed."
                            exit 0
                        fi

                        echo "Waiting for test container... attempt ${attempt}/15"
                        sleep 2
                    done

                    echo "Application health check failed."
                    docker logs "$TEST_CONTAINER" || true
                    exit 1
                '''
            }
        }

        stage('Deploy with Terraform') {
            steps {
                sh '''
                    set -eux

                    terraform -chdir=terraform apply \
                      -input=false \
                      -auto-approve \
                      -var="image_name=${IMAGE_REPOSITORY}:${BUILD_NUMBER}" \
                      -var="container_name=${CONTAINER_NAME}" \
                      -var="host_port=${APPLICATION_PORT}"
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                    set -eux

                    echo "Checking deployed Docker container..."

                    docker ps --filter "name=^/${CONTAINER_NAME}$"

                    STATUS=$(docker inspect \
                      --format='{{.State.Status}}' \
                      "${CONTAINER_NAME}")

                    if [ "$STATUS" != "running" ]; then
                        echo "Container is not running."
                        docker logs "${CONTAINER_NAME}" || true
                        exit 1
                    fi

                    echo "Waiting for deployed application..."

                    VERIFIED=false

                    for attempt in $(seq 1 20); do
                        if curl --fail --silent \
                          http://host.docker.internal:${APPLICATION_PORT}/health \
                          | grep -q '"status":"ok"'; then

                            echo "Deployment health check passed."
                            VERIFIED=true
                            break
                        fi

                        echo "Waiting for deployment... attempt ${attempt}/20"
                        sleep 2
                    done

                    if [ "$VERIFIED" != "true" ]; then
                        echo "Deployment health check failed."
                        docker logs "${CONTAINER_NAME}" || true
                        exit 1
                    fi

                    terraform -chdir=terraform output

                    echo "Deployment verified successfully."
                '''
            }
        }
    }

    post {
        always {
            sh '''
                docker rm -f "${CONTAINER_NAME}-test-${BUILD_NUMBER}" \
                  >/dev/null 2>&1 || true

                docker image prune -f || true
            '''
        }

        success {
            echo 'Pipeline succeeded. Open http://localhost:5000'
        }

        failure {
            echo 'Pipeline failed. Review the stage logs above.'
        }
    }
}