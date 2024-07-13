pipeline {
    agent { 
        label 'my_ubuntu' 
    }
    
    environment {
        DOCKER_HUB_CREDENTIALS = 'dockerhub_credentials'
        GIT_REPO = 'https://github.com/yosef-ruvinov/ecommerce-django-react.git'
        SLACK_CHANNEL = '#devops-ecommerce'
        SLACK_CREDENTIALS = 'slack_token'
        AWS_CREDENTIALS = 'aws_credentials'
        AWS_REGION = 'il-central-1'
        DOCKER_IMAGE = 'yossiruvinovdocker/ecommerce-project'
        DOCKER_TAG = 'latest'
        INSTANCE = 'My Ubuntu'
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
                    sh 'docker stop ecommerce_project_container || true'
                    sh 'docker rm ecommerce_project_container || true'
                }
            }
        }

        stage('Kill Existing Image') {
            steps {
                script {
                    sh 'docker rmi ${DOCKER_IMAGE}:${DOCKER_TAG} || true'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${DOCKER_IMAGE}:${DOCKER_TAG}", "-f Dockerfile .")
                }
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKER_HUB_CREDENTIALS}", usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    script {
                        docker.withRegistry('https://index.docker.io/v1/', "${DOCKER_HUB_CREDENTIALS}") {
                            def image = docker.image("${DOCKER_IMAGE}:${DOCKER_TAG}")
                            image.push()
                        }
                    }
                }
            }
        }

        stage('Run Docker Container') {
            steps {
                script {
                    def containerName = "ecommerce_project_container"
                    sh """
                    if [ \$(docker ps -a -q -f name=${containerName}) ]; then
                        docker stop ${containerName}
                        docker rm ${containerName}
                    fi
                    docker run -d --name ${containerName} -p 8000:8000 ${DOCKER_IMAGE}:${DOCKER_TAG}
                    """
                }
            }
        }

        stage('Test') {
            steps {
                script {
                    def containerName = "ecommerce_project_container"
                    sh "docker exec ${containerName} pytest test/api/test_products.py || error('Unit tests failed')"
                    sh "docker exec ${containerName} pytest test/api/test_user.py || error('Unit tests failed')"
                }
            }
        }
    }

    post {
        success {
            script {
                slackSend (
                    color: 'good', 
                    channel: "${SLACK_CHANNEL}",
                    tokenCredentialId: "${SLACK_CREDENTIALS}",
                    message: "Successful Deployment! Build '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})"
                )
            }
        }

        failure {
            script {
                slackSend (
                    color: 'danger', 
                    channel: "${SLACK_CHANNEL}", 
                    tokenCredentialId: "${SLACK_CREDENTIALS}", 
                    message: "Failed Deployment! Build '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})"
                )
            }
        }

        always {
            cleanWs()
        }
    }
}
