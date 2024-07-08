pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/yosef-ruvinov/ecommerce-django-react.git', branch: 'main'
            }
        }
        stage('Build') {
            steps {
                sh 'make build'
            }
        }
        stage('Test') {
            steps {
                sh 'make test'
            }
        }
        stage('Docker Build') {
            steps {
                script {
                    def dockerImage = docker.build("yourdockerhubusername/ecommerce-django-react")
                    dockerImage.push()
                }
            }
        }
        stage('Deploy') {
            steps {
                // Deployment steps go here
                echo 'Deploying the application...'
            }
        }
    }
    post {
        failure {
            slackSend(channel: '#yourchannel', message: "Build failed: ${currentBuild.fullDisplayName}")
        }
    }
}
