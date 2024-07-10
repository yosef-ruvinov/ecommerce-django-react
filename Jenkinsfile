pipeline {
    agent any
    environment {
        DOCKER_HUB_CREDENTIALS = 'dockerhub_credentials'  
        GIT_REPO = 'https://github.com/yosef-ruvinov/ecommerce-django-react.git'  
        SLACK_CHANNEL = '#devops-ecommerce'  
        SLACK_CREDENTIALS = 'slack_webhook'
        AWS_CREDENTIALS = 'aws_credentials'2
        AWS_REGION = 'il-central-1'
        INSTANCE = 'My Ubuntu'
    }

    stages {
        stage('Checkout') {
            steps {
                git url: "${GIT_REPO}", branch: 'main'  
            }
        }

        stage('Build') {
            agent { label 'My-Ubuntu' }
            steps {
                    script {
                        def containerName = "yosef_container"
                        sh """
                        if [ \$(docker ps -a -q -f name=${containerName}) ]; then
                            docker stop ${containerName}
                            docker rm ${containerName}
                        fi
                        """
                        sh "docker build --no-cache -t yosef-ruvinov/ecommerce-django-react:${env.BUILD_NUMBER} ."
                    }
                }
            }

        stage('Test') {
            steps {
                script {
                    docker.image("yossiruvinovdocker/ecommerce-project:${BUILD_NUMBER}").inside {
                        sh 'pytest test/api/test_products.py' || error("Unit tests failed")  // Run unit tests
                        sh 'pytest test/api/test_user.py' || error("Unit tests failed")      // Run unit tests
                        sh 'pytest --driver Chrome' || error("E2E tests failed")            // Run E2E tests with Selenium 
                    }
                }
            }
            post {
                failure {
                    slackSend (
                        color: 'good',
                        message: "Build succeeded: ${env.JOB_NAME} [${env.BUILD_NUMBER}] (${env.BUILD_URL})",
                        channel: env.SLACK_CHANNEL,
                        tokenCredentialId: env.SLACK_CREDENTIALS
                    )
                }
                success {
                    slackSend (
                        color: 'danger',
                        message: "Build failed: ${env.JOB_NAME} [${env.BUILD_NUMBER}] (${env.BUILD_URL})",
                        channel: env.SLACK_CHANNEL,
                        tokenCredentialId: env.SLACK_CREDENTIALS           
                    )
                }
            }
        }

    //     stage('Push') {
    //         steps {
    //             withCredentials([usernamePassword(credentialsId: 'dockerhub_credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
    //                 sh 'docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD'
    //                 sh 'docker push yossiruvinovdocker/ecommerce-project:${BUILD_NUMBER}'  // Replace with your Docker image name and tag
    //             }
    //         }
    //     }

    //     stage('Deployment') {
    //         steps {
    //             // Add deployment steps here
    //             sh 'docker stack deploy -c docker-compose.yml your-app-stack'  // Replace with your deployment details
    //         }
    //     }
    // }
}
