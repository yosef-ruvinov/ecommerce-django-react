pipeline {
    agent any
    environment{
        DOCKER_USERNAME = yossiruvinovdocker
        DOCKER_HUB_CREDENTIAL = 
        GIT_REPO = "https://github.com/yosef-ruvinov/ecommerce-django-react.git"
        SLACK_CHANNEL = "https://devops-ecommerece.slack.com/archives/C07A7HP27BQ"
        AWS_CREDENTIALS = 
    }

    stages {
        stage('Checkout') {
            steps {
                git url: "${GIT_REPO}", branch: 'main'
            }
        }
        }

        stage('Build') {
            steps {
                sh 'docker build -t yossiruvinovdocker/ecommerce-project:"${BUILD_NUM}" .'
            }
        }

        // stage('Test') {
        //     steps {
        //         script {
        //             def testResult = sh returnStatus: true, script: 'your test commands here' // Replace 'your test commands here' with your actual test commands
        //             if (testResult == 0) {
        //                 currentBuild.result = 'SUCCESS'
        //             } else {
        //                 currentBuild.result = 'FAILURE'
        //             }
        //         }
            // }
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
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh 'docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD'
                    sh 'docker push your-docker-image:tag' // Replace 'your-docker-image:tag' with your Docker image name and tag
                }
            }
        }

        stage('Deployment') {
            steps {
                // Add deployment steps here, e.g., deploying to Docker node
                sh 'docker stack deploy -c docker-compose.yml your-app-stack' // Replace 'docker-compose.yml' and 'your-app-stack' with your deployment details
            }
        }