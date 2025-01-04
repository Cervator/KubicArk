pipeline {
    agent {
        label 'kubectl'
    }

    stages {
        stage('Backup') {
            steps {
                withKubeConfig(credentialsId: 'utility-admin-kubeconfig-sa-token') {
                    // Get the server name from the folder name
                    def serverName = env.JOB_NAME.tokenize('/')[0] 

                    sh("This job is for ${serverName}")
                    sh("kubectl get ns")
                }
            }
        }
    }
}