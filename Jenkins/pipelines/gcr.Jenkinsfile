pipeline {
    agent any
 
    environment {
        DISCORD_WEBHOOK = credentials('discord-webhook')
        GIT_URL = 'https://github.com/ismoilovdevml/devops-journey.git'
        GCR_CREDENTIALS = credentials('gcr-key')
        GCP_PROJECT_ID = credentials('gcp-project-id')
        CONTAINER_NAME = 'devops-journey'
        REGISTRY_URL = 'gcr.io'
        SERVER_USERNAME = credentials('server-username')
        SERVER_IP = credentials('server-ip')
        SSH_CREDENTIALS = credentials('server-ssh')
        GIT_TOKEN = credentials('git-token')
        BRANCH_NAME = 'main'
    }
 
    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }
 
        stage('Clone Repository') {
            steps {
                git branch: BRANCH_NAME, url: GIT_URL, credentialsId: 'git-token'
            }
        }
 
        stage('Build and Push Docker Image') {
            steps {
                script {
                    def dockerImage = "${REGISTRY_URL}/${GCP_PROJECT_ID}/${CONTAINER_NAME}:${BUILD_NUMBER}"
 
                    sh """
                        cat ${GCR_CREDENTIALS} | docker login -u _json_key --password-stdin https://gcr.io
                        docker build . -t ${dockerImage} -f Dockerfile
                        docker push ${dockerImage}
                        docker tag ${dockerImage} ${REGISTRY_URL}/${GCP_PROJECT_ID}/${CONTAINER_NAME}:latest
                        docker push ${REGISTRY_URL}/${GCP_PROJECT_ID}/${CONTAINER_NAME}:latest
                        docker image rm -f ${dockerImage}
                        docker image rm -f ${REGISTRY_URL}/${GCP_PROJECT_ID}/${CONTAINER_NAME}:latest
                    """
                }
            }
        }
        stage('Deploy to Server') {
            steps {
                script {
                    sshagent(credentials: ['server-ssh']) {
                        // Copy the GCR credentials to the server
                        sh "scp -o StrictHostKeyChecking=no ${GCR_CREDENTIALS} ${SERVER_USERNAME}@${SERVER_IP}:/tmp/gcr-key.json"
                        // Log in to GCR on the server using the copied credentials
                        sh """
                            ssh -o StrictHostKeyChecking=no ${SERVER_USERNAME}@${SERVER_IP} \
                            'cat /tmp/gcr-key.json | docker login -u _json_key --password-stdin https://gcr.io'
                        """
                        // Continue with the rest of the deployment steps
                        sh """
                            ssh -o StrictHostKeyChecking=no ${SERVER_USERNAME}@${SERVER_IP} '\
                            docker pull ${REGISTRY_URL}/${GCP_PROJECT_ID}/${CONTAINER_NAME}:latest && \
                            docker stop ${CONTAINER_NAME} || true && \
                            docker rm ${CONTAINER_NAME} || true && \
                            docker run -d -p 3000:3000 --name ${CONTAINER_NAME} --restart always ${REGISTRY_URL}/${GCP_PROJECT_ID}/${CONTAINER_NAME}:latest '
                        """
                    }
                }
            }
        }
    }
    post {
        always {
            script {
                try {
                    // Delete the copied GCR credentials from the server
                    sshagent(credentials: ['server-ssh']) {
                        sh """
                            ssh -o StrictHostKeyChecking=no ${SERVER_USERNAME}@${SERVER_IP} \
                            'rm /tmp/gcr-key.json'
                        """
                    }
                } catch (Exception e) {
                    echo "Error cleaning up GCR credentials: ${e.message}"
                    currentBuild.result = 'FAILURE' // Set build result to FAILURE in case of errors
                } finally {
                    // Send Discord notification regardless of the build result
                    discordSend(
                        description: "Jenkins Pipeline Build ${currentBuild.currentResult}",
                        link: GIT_URL,
                        result: currentBuild.currentResult,
                        title: JOB_NAME,
                        webhookURL: DISCORD_WEBHOOK
                    )
                }
            }
        }
    }
}