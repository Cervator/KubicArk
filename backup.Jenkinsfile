pipeline {
    agent {
        label 'kubectl && gcloud'
    }
    
    environment {
        serverName = "${env.JOB_NAME.tokenize('/')[1]}" 
    }

    stages {
        stage('Backup') {
            steps {
                container("utility") {
                    
                    // Go create the actual backup file and retrieve a copy
                    withKubeConfig(credentialsId: 'utility-admin-kubeconfig-sa-token') {
                        echo "Hello World $serverName"
                        sh "kubectl get ns"
                    }
                    
                    // Take the locally stored backup and place it into a GCP bucket 
                    withCredentials([file(credentialsId: 'jenkins-bucket-sa', variable: 'GCLOUD_KEY')]) {
                        sh '''
                            # Authenticate to GCloud by cramming the credential file right into the auth via standard in
                            cat "$GCLOUD_KEY" | gcloud auth activate-service-account --key-file=-
                            
                            # Get the current timestamp to make a unique file name
                            timestamp=$(date +%Y%m%d-%H%M%S)

                            echo "This is a test file from Jenkins." > test-file-${timestamp}.txt

                            gsutil cp test-file-${timestamp}.txt gs://kubic-game-hosting/test-object-${timestamp}.txt
                        '''
                    }
                }
            }
        }
    }
}