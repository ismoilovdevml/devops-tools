pipeline {
    agent any
 
    environment {
        DISCORD_WEBHOOK = credentials('discord-webhook')
        GIT_URL = 'https://github.com/ismoilovdevml/devops-journey.git'
        DOCKERHUB_CREDENTIALS = credentials('dockerhub')
        CONTAINER_NAME = 'devops-journey'
        REGISTRY_URL = 'devsecopsuser732'
        GIT_TOKEN = credentials('git-token')
        SERVER_USERNAME = credentials('server-username')
        SERVER_IP = credentials('server-ip')
        SSH_CREDENTIALS = credentials('server-ssh')
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
        stage('Build Application') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    script {
                        def dockerlogin = "docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD}"
                        sh dockerlogin
                        sh """
                            docker build . -t ${REGISTRY_URL}/${CONTAINER_NAME}:${BUILD_NUMBER} -f Dockerfile
                            docker tag ${REGISTRY_URL}/${CONTAINER_NAME}:${BUILD_NUMBER} ${REGISTRY_URL}/${CONTAINER_NAME}:latest
                            docker push ${REGISTRY_URL}/${CONTAINER_NAME}:latest
                            docker push ${REGISTRY_URL}/${CONTAINER_NAME}:${BUILD_NUMBER}
                            docker image rm -f ${REGISTRY_URL}/${CONTAINER_NAME}:latest
                            docker image rm -f ${REGISTRY_URL}/${CONTAINER_NAME}:${BUILD_NUMBER}
                        """
                    }
                }    
            }
        }
        stage('Deploy Server') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    script {
                        sshagent (credentials: ['server-ssh']) {
                            sh """
                                ssh -o StrictHostKeyChecking=no ${SERVER_USERNAME}@${SERVER_IP} '\
                                docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD} && \
                                docker pull ${REGISTRY_URL}/${CONTAINER_NAME}:latest && \
                                docker stop ${CONTAINER_NAME} || true && \
                                docker rm ${CONTAINER_NAME} || true && \
                                docker run -d -p 3000:3000 --name ${CONTAINER_NAME} --restart always ${REGISTRY_URL}/${CONTAINER_NAME}:latest '
                            """
                        }
                    }
                }    
            }
        }
    }
    post {
        always {
            discordSend(
                description: "Jenkins Pipeline Build ${currentBuild.currentResult}",
                link: env.GIT_URL,
                result: currentBuild.currentResult,
                title: JOB_NAME,
                webhookURL: env.DISCORD_WEBHOOK
            )
        }
    }
}