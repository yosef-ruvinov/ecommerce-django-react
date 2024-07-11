pipeline {
    agent { label 'my_ubuntu' }
    
    environment {
        DOCKER_HUB_CREDENTIALS = 'dockerhub_credentials'
        GIT_REPO = 'https://github.com/yosef-ruvinov/ecommerce-django-react.git'
        SLACK_CHANNEL = '#devops-ecommerce'
        SLACK_CREDENTIALS = 'slack_token'
        AWS_CREDENTIALS = 'aws_credentials'
        AWS_REGION = 'il-central-1'
        INSTANCE = 'My Ubuntu'
    }

    stages {
        stage('Checkout') {
            agent { label 'my_ubuntu' }
            steps {
                git url: "${GIT_REPO}", branch: 'main'
            }
        }

        stage('Build Docker Image') {
            agent { label 'my_ubuntu' }
            steps {
                script {
                    docker.build("python-app:latest", "-f Dockerfile .")
                }
            }
        }

        stage('Docker Push') {
            agent { label 'my_ubuntu' }
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub_credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh 'echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin'
                        sh "docker push yosef-ruvinov/ecommerce-django-react:${env.BUILD_NUMBER}"
                    }
                }
            }
        }

        stage('Run Docker Container') {
            agent { label 'my_ubuntu' }
            steps {
                script {
                    def containerName = "yosef_container"
                    sh """
                    if [ \$(docker ps -a -q -f name=${containerName}) ]; then
                        docker stop ${containerName}
                        docker rm ${containerName}
                    fi
                    docker run -d --name ${containerName} -p 8000:8000 yosef-ruvinov/ecommerce-django-react:${env.BUILD_NUMBER}
                    """
                }
            }
        }
    }

    post {
        success {
            slackSend (
                color: 'good',
                message: "Build succeeded: ${env.JOB_NAME} [${env.BUILD_NUMBER}] (${env.BUILD_URL})",
                channel: env.SLACK_CHANNEL,
                tokenCredentialId: env.SLACK_CREDENTIALS
            )
        }
        failure {
            slackSend (
                color: 'danger',
                message: "Build failed: ${env.JOB_NAME} [${env.BUILD_NUMBER}] (${env.BUILD_URL})",
                channel: env.SLACK_CHANNEL,
                tokenCredentialId: env.SLACK_CREDENTIALS
            )
        }
        always {
            cleanWs()
        }
    }
}