pipeline {
    agent any
    environment {
        DOCKER_USERNAME = 'yossiruvinovdocker'  
        DOCKER_HUB_CREDENTIAL = 'dockerhub_credentials'  
        GIT_REPO = 'https://github.com/yosef-ruvinov/ecommerce-django-react.git'  
        SLACK_CHANNEL = '#devops-ecommerce'  
        AWS_CREDENTIALS = 'aws_credentials'
    }

    stages {
        stage('Checkout') {
            steps {
                git url: "${GIT_REPO}", branch: 'main'  // Checkout your git repo
            }
        }

        stage('Build') {
            steps {
                sh 'docker build -t yossiruvinovdocker/ecommerce-project:${BUILD_NUMBER} .'  // Build the docker image
            }
        }

        stage('Test') {
            steps {
                script {
                    def testResult = sh returnStatus: true, script: 'your test commands here'  // *** Replace with your actual test commands
                    if (testResult == 0) {
                        currentBuild.result = 'SUCCESS'
                    } else {
                        currentBuild.result = 'FAILURE'
                    }
                }
            }
            post {
                failure {
                    slackSend (
                        channel: env.SLACK_CHANNEL,
                        color: 'danger',
                        message: "Build failed: ${env.JOB_NAME} [${env.BUILD_NUMBER}] (${env.BUILD_URL})"
                    )
                }
                success {
                    slackSend (
                        channel: env.SLACK_CHANNEL,
                        color: 'good',
                        message: "Build succeeded: ${env.JOB_NAME} [${env.BUILD_NUMBER}] (${env.BUILD_URL})"
                    )
                }
            }
        }

        stage('Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'your-docker-hub-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh 'docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD'
                    sh 'docker push yossiruvinovdocker/ecommerce-project:${BUILD_NUMBER}'  // Replace with your Docker image name and tag
                }
            }
        }

        stage('Deployment') {
            steps {
                // Add deployment steps here
                sh 'docker stack deploy -c docker-compose.yml your-app-stack'  // Replace with your deployment details
            }
        }
    }
}
