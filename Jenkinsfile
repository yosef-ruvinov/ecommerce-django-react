pipeline {
    agent { label 'my_ubuntu' }
    
    environment {
        DOCKER_HUB_CREDENTIALS = 'dockerhub_credentials'
        GIT_REPO = 'https://github.com/yosef-ruvinov/ecommerce-django-react.git'
        SLACK_CHANNEL = '#devops-ecommerce'
        SLACK_CREDENTIALS = 'slack_token'
        AWS_CREDENTIALS = 'aws_credentials'
        AWS_REGION = 'il-central-1'
        DOCKER_IMAGE = 'ecommerce-app'
        DOCKER_TAG = 'latest'
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
            agent { label 'my_ubuntudd' }
            steps {
                script {
                    docker.build("${DOCKER_IMAGE}:${DOCKER_TAG}", "-f Dockerfile .")
                }
            }
        }

        stage('Docker Push') {
            agent { label 'my_ubuntu' }
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub_credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    script {
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub_credentials') {
                    def image = docker.image("${DOCKER_IMAGE}:${DOCKER_TAG}")
                    image.push()
                }
            }
        }
    }
}



        stage('Run Docker Container') {
            agent { label 'my_ubuntu' }
            steps {
                script {
                    def containerName = "${DOCKER_IMAGE}_container"
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

    }
        // stage('Test') {
        //     agent { label 'my_ubuntu' }
        //     steps {
        //         script {
        //             def containerName = "yosef_container"
        //             sh "docker exec ${containerName} pytest test/api/test_products.py || error('Unit tests failed')"
        //             sh "docker exec ${containerName} pytest test/api/test_user.py || error('Unit tests failed')"
        //             sh "docker exec ${containerName} pytest --driver Chrome || error('E2E tests failed')"
        //         }
        //     }
        // }

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
