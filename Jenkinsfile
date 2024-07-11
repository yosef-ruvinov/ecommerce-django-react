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
                    docker.withRegistry('https://registry-1.docker.io', DOCKER_HUB_CREDENTIALS) {
                        def dockerImage = docker.build("python-app:latest", "-f Dockerfile .")
                        dockerImage.push()
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
