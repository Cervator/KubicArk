// This DSL script iterates through ARK game server/map names in a list then makes a folder for each server with utility jobs within

def serverMaps = [
    "island",      // Ports: 31101-31104
    "center",      // Ports: 31111-31114
    "scorched",    // Ports: 31121-31124
    "ragnarok",    // Ports: 31131-31134
    "aberration",  // Ports: 31141-31144
    "extinction",  // Ports: 31151-31154
    "valguero",    // Ports: 31161-31164
    "genesis1",    // Ports: 31171-31174
    "genesis2",    // Ports: 31181-31184
    "crystal",     // Ports: 31191-31194
    "lost",        // Ports: 31201-31204
    "fjordur"      // Ports: 31211-31214
]

def parentGameFolder = "KubicGameHosting/ARK" 
folder("KubicGameHosting")  
folder(parentGameFolder)    

// Print the map keys and values 
serverMaps.each { serverName ->
    println "$serverName"

    folder("${parentGameFolder}/${serverName}") {  
        displayName(serverName.capitalize()) 
    }

    pipelineJob("${parentGameFolder}/${serverName}/backup") { 
        displayName("Back up server") 

        definition {
            cpsScm {
                scm {
                    git { 
                        remote {
                            url('https://github.com/Cervator/KubicArk.git')
                            credentials('GooeyHub')
                        }
                        branch('main') 
                    }
                }
                scriptPath('backup.Jenkinsfile') 
            }
        }
    }

    pipelineJob("${parentGameFolder}/${serverName}/start") {
        displayName("Start server")

        definition {
            cpsScm {
                scm {
                    git {
                        remote {
                            url('https://github.com/Cervator/KubicArk.git')
                            credentials('GooeyHub')
                        }
                        branch('main')
                    }
                }
                scriptPath('start.Jenkinsfile')
            }
        }
    }
}