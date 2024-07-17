pipeline {
    agent { 
        label 'my_ubuntu' 
    }
    
    environment {
        DOCKER_HUB_CREDENTIALS = 'dockerhub_credentials'
        GIT_REPO = 'https://github.com/yosef-ruvinov/ecommerce-django-react.git'
        SLACK_CHANNEL = '#deployment-notifications'
        SLACK_TOKEN = 'jenkins_ci_token'
        AWS_CREDENTIALS = 'aws_credentials'
        AWS_REGION = 'il-central-1'
        DOCKER_IMAGE = 'yossiruvinovdocker/ecommerce-project'
        DOCKER_TAG = 'latest'
        CONTAINER_NAME = 'devops_project_container'
    }

    stages {
        stage('Checkout') {
            steps {
                git url: "${GIT_REPO}", branch: 'main'
            }
        }

        stage('Kill Existing Container') {
            steps {
                script {
                    sh 'docker stop ${CONTAINER_NAME} || true'
                    sh 'docker rm ${CONTAINER_NAME} || true'
                }
            }
        }

        stage('Remove Existing Image') {
            steps {
                script {
                    sh 'docker rmi ${DOCKER_IMAGE}:${DOCKER_TAG} || true'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} -f Dockerfile .'
                }
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', "${DOCKER_HUB_CREDENTIALS}") {
                        sh 'docker push ${DOCKER_IMAGE}:${DOCKER_TAG}'
                    }
                }
            }
        }

        stage('Deploy Docker Container') {
            steps {
                script {
                    sh """
                    if [ \$(docker ps -a -q -f name=${CONTAINER_NAME}) ]; then
                        docker stop ${CONTAINER_NAME}
                        docker rm ${CONTAINER_NAME}
                    fi
                    docker run -d --name ${CONTAINER_NAME} -p 8000:8000 ${DOCKER_IMAGE}:${DOCKER_TAG}
                    """
                }
            }
        }

        stage('Test') {
            steps {
                script {
                    try {
                        // Ensure Docker container is running
                        sh "docker start ${CONTAINER_NAME}"
                        
                        // Run pytest commands within Docker container
                        sh "docker exec ${CONTAINER_NAME} python manage.py test"
                        sh "docker exec ${CONTAINER_NAME} pytest tests/api/test_products.py"
                        sh "docker exec ${CONTAINER_NAME} pytest tests/api/test_user.py"
                        
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        throw e
                    } finally {
                        // Stop Docker container after tests
                        sh "docker stop ${CONTAINER_NAME}"
                    }
                }
            }
        }
    }

    post {
        success {
            script {
                slackSend(channel: SLACK_CHANNEL, color: 'good', message: "Build ${env.BUILD_NUMBER} Success: ${env.BUILD_URL}", tokenCredentialId: SLACK_TOKEN)
            }
            echo 'Deployment successful!'
        }
        failure {
            script {
                slackSend(channel: SLACK_CHANNEL, color: 'danger', message: "Build ${env.BUILD_NUMBER} Failed: ${env.BUILD_URL}", tokenCredentialId: SLACK_TOKEN)
            }
            echo 'Deployment failed!'
        }     
    }
}