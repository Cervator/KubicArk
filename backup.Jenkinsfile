pipeline {
    agent {
        label 'kubectl && gcloud'
    }
    
    environment {
        // Use the parent folder name as server name. If the path changes the index here may need to change too!
        serverName = "${env.JOB_NAME.tokenize('/')[2]}" 
    }

    stages {
        stage('Backup') {
            steps {
                container("utility") {
                    
                    // Authenticate with Kubernetes and GCP bucket access then run the backup script
                    withKubeConfig(credentialsId: 'utility-admin-kubeconfig-sa-token') {
                        withCredentials([file(credentialsId: 'jenkins-bucket-sa', variable: 'GCLOUD_KEY')]) {
                            sh 'cat "$GCLOUD_KEY" | gcloud auth activate-service-account --key-file=-'
                            sh './backup-server.sh $serverName'
                        }
                    }
                }
            }
        }
    }
}
