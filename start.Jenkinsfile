pipeline {
    agent {
        label 'kubectl'
    }

    environment {
        // Use the parent folder name as server name. If the path changes the index here may need to change too!
        serverName = "${env.JOB_NAME.tokenize('/')[2]}"
    }

    stages {
        stage('Check for Secret') {
            steps {
                git branch: 'main', credentialsId: 'GooeyHub', url: 'https://github.com/Cervator/KubicArk.git' //TODO remove before committing
                container("utility") {
                    // Authenticate with Kubernetes and see if an optional secret exists
                    withKubeConfig(credentialsId: 'utility-admin-kubeconfig-sa-token') {
                        script {
                            def secretName = 'ark-unattended-install-secrets'
                            def namespace = 'ark'

                            try {
                                def secretExists = sh(returnStdout: true, script: "kubectl get secret ${secretName} -n ${namespace} -o name").trim()
                                echo "Secret '${secretName}' found in namespace '${namespace}'"
                                env.secretExists = true
                                env.SECRET_PASSWORD = sh(returnStdout: true, script: "kubectl get secret ${secretName} -n ${namespace} -o jsonpath='{.data.serverPass}' | base64 -d").trim()
                                env.ADMIN_PASSWORD = sh(returnStdout: true, script: "kubectl get secret ${secretName} -n ${namespace} -o jsonpath='{.data.adminPass}' | base64 -d").trim()
                                echo "Retrieved server and admin passwords from secret"
                            } catch (err) {
                                echo "Secret '${secretName}' not found in namespace '${namespace}'. No password update will be performed."
                                env.secretExists = false
                            }
                        }
                    }
                }
            }
        }

        stage('Apply optional secret') {
            when {
                expression {secretExists && secretExists.equals("true")}
            }
            steps {
                script {
                    if (env.SECRET_PASSWORD == '') {
                        sh """
                            sed -i "s/default/\\\"\\\"/g" ark-server-secrets.yaml
                            cat ark-server-secrets.yaml
                        """
                    } else {
                        sh """
                            sed -i "s/default/${env.SECRET_PASSWORD}/g" ark-server-secrets.yaml
                            cat ark-server-secrets.yaml 
                        """
                    }
                }
            }
        }

        stage('Launch ARK server') {
            steps {
                container("utility") {
                    withKubeConfig(credentialsId: 'utility-admin-kubeconfig-sa-token') {
                        script {
                            // Apply the server secrets first
                            sh "kubectl apply -f ark-server-secrets.yaml -n ark"
                            
                            // Apply the server configuration
                            sh """
                                kubectl apply -f ${serverName}/ark-service.yaml -n ark
                                kubectl apply -f ${serverName}/ark-pvc.yaml -n ark
                                kubectl apply -f ${serverName}/OverrideGameUserSettingsCM.yaml -n ark
                                kubectl apply -f ${serverName}/OverrideGameIniCM.yaml -n ark
                                kubectl apply -f ${serverName}/ark-statefulset.yaml -n ark
                            """
                            
                            // Wait for the StatefulSet to be ready
                            sh "kubectl rollout status statefulset/ark${serverName} -n ark --timeout=300s"
                            
                            echo "ARK server for ${serverName} has been launched successfully"
                        }
                    }
                }
            }
        }
    }
    
    post {
        failure {
            echo "Timed out waiting to launch ARK server for ${serverName}. Check the logs for details - server may be fine later."
        }
    }
}