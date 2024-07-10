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
                git url: "${GIT_REPO}", branch: 'main'  
            }
        }

        stage('Build') {
            steps {
                sh 'docker build -t yossiruvinovdocker/ecommerce-project:${BUILD_NUMBER} .'  
            }
        }

        stage('Test') {
            steps {
                script {
                    docker.image("yossiruvinovdocker/ecommerce-project:${BUILD_NUMBER}").inside {
                        sh 'pytest test/api/test_products.py'  // Run unit tests
                        sh 'pytest test/api/test_user.py'      // Run unit tests
                        sh 'pytest --driver Chrome'            // Run E2E tests with Selenium 
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

        // Commenting out the 'Push' and 'Deployment' stages for faster testing
        /*
        stage('Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub_credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
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
        */
    }
}
