pipeline {
    agent any 

    options {
      gitLabConnection('git.ismoilovdev.uz')
      gitlabBuilds(builds: ['setup-env','build'])
      skipDefaultCheckout() 
    }
    environment {
        CONFIGURATIONS_GIT_URL="https://git.ismoilovdev.uz/resources/configurations.git"
        GIT_URL = "https://git.ismoilovdev.uz/ismoilovdev-development/open-source-project/os-dev-blog.git"
        REGISTRY_URL="git.ismoilovdev.uz:5050/ismoilovdev-development/open-source-project/os-dev-blog"
        BUILD_BRANCH='dev'
    }

    triggers {
        gitlab(triggerOnPush: true, triggerOnMergeRequest: true, branchFilterType: 'All')
    }

    stages {
        stage('Checkout Gitlab'){
            steps {
                script{
                    if(env.BRANCH_NAME == "dev" || env.BRANCH_NAME == "stage" || env.BRANCH_NAME == "prod" ){
                        BUILD_BRANCH = env.BRANCH_NAME
                    }else{
                        BUILD_BRANCH = 'dev'
                    }
                }
            }
        }
        stage(' Setup Environment') {
            steps{
                updateGitlabCommitStatus name: 'setup-env', state: 'running'
                    dir('configurations'){
                        git branch: 'main', url: CONFIGURATIONS_GIT_URL, credentialsId: 'afcc10c9-09a0-4fa3-83c6-f7e533c485b0'
                        }

                    sh "cp configurations/os-dev-blog/${BUILD_BRANCH}/Dockerfile ./Dockerfile"
                    dir('ismoilovdevml/os-dev-blog') { git branch:BUILD_BRANCH, url:EXTERNAL_INTEGRATIONS_GIT_URL, credentialsId: 'afcc10c9-09a0-4fa3-83c6-f7e533c485b0' }
                updateGitlabCommitStatus name: 'setup-env', state: 'success'
            }
        }
         stage("Build Application") {
             when {
                expression {
                    BRANCH_NAME == 'dev' || BRANCH_NAME == 'stage' || BRANCH_NAME == 'prod' 
                }
            }
            steps{
                withCredentials([string(
                        credentialsId: 'gitlab-api-token',
                        variable: 'GIT_API_TOKEN'
                     )]) {
                        sh "echo ${GIT_API_TOKEN} | docker login git.ismoilovdev.uz:5050 -u devops --password-stdin"
                     }
                sh "docker build . -t ${REGISTRY_URL}/blog-${BRANCH_NAME}:${BUILD_NUMBER} -f Dockerfile"
                sh "docker tag ${REGISTRY_URL}/blog-${BRANCH_NAME}:${BUILD_NUMBER} ${REGISTRY_URL}/blog-${BRANCH_NAME}:latest"
                sh "docker push ${REGISTRY_URL}/blog-${BRANCH_NAME}:latest"
                sh "docker push ${REGISTRY_URL}/blog-${BRANCH_NAME}:${BUILD_NUMBER}"
                
                sh "docker image rm -f ${REGISTRY_URL}/blog-${BRANCH_NAME}:latest"
                sh "docker image rm -f ${REGISTRY_URL}/blog-${BRANCH_NAME}:${BUILD_NUMBER}"
            }
        }

        stage("Run Application to Development Servers"){
            when {
                expression {
                    BRANCH_NAME == 'dev'
                }
            }
            steps{
                withCredentials([string(
                        credentialsId: 'gitlab-api-token',
                        variable: 'GIT_API_TOKEN'
                     )]) {
                        sshagent(['dev-app-ssh-key']) {
                sh "ssh -o StrictHostKeyChecking=no dev-server@192.168.1.46 '~/scripts/deployer.sh --image=${REGISTRY_URL}/blog-${BRANCH_NAME}:${BUILD_NUMBER} --container-port=15185 --system-port=15185 --registry-host=git.ismoilovdev.uz:5050 --container-name=os-dev-blog --registry-token=${GIT_API_TOKEN} --registry-user=devops'"
                     }
                     }
            }
        }
        stage("Run Application to Staging Servers"){
            when {
                expression {
                    BRANCH_NAME == 'stage'
                }
            }
            steps{
                withCredentials([string(
                        credentialsId: 'gitlab-api-token',
                        variable: 'GIT_API_TOKEN'
                     )]) {
                        sshagent(['stage-app-ssh-key']) { 
                sh "ssh -o StrictHostKeyChecking=no stage-server@192.168.1.42 -p 53274 '~/scripts/deployer.sh --image=${REGISTRY_URL}/blog-${BRANCH_NAME}:${BUILD_NUMBER} --container-port=15185 --system-port=15185 --registry-host=git.ismoilovdev.uz:5050 --container-name=os-dev-blog --registry-token=${GIT_API_TOKEN} --registry-user=devops'"
                    }
                     }
            }
        }
        stage("Run Application to Production Servers"){
            when {
                expression {
                    BRANCH_NAME == 'stage'
                }
            }
            steps{
                withCredentials([string(
                        credentialsId: 'gitlab-api-token',
                        variable: 'GIT_API_TOKEN'
                     )]) {
                        sshagent(['stage-app-ssh-key']) { 
                sh "ssh -o StrictHostKeyChecking=no stage-server@195.168.1.45 -p 53274 '~/scripts/deployer.sh --image=${REGISTRY_URL}/blog-${BRANCH_NAME}:${BUILD_NUMBER} --container-port=15185 --system-port=15185 --registry-host=git.ismoilovdev.uz:5050 --container-name=os-dev-blog --registry-token=${GIT_API_TOKEN} --registry-user=devops'"
                    }
                     }
            }
        }
    }
     post {
        failure {
            updateGitlabCommitStatus name: 'build', state: 'failed'
        }

        success {
            sh "echo 'Success'"
            updateGitlabCommitStatus name: 'build', state: 'success'
        }
        aborted {
            
            updateGitlabCommitStatus name: 'build', state: 'canceled'
        }
        always {
            cleanWs()
        }
    }
}
