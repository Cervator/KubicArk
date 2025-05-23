// This DSL script iterates through ARK game server/map names in a list then makes a folder for each server with utility jobs within

def serverMaps = [
    "island",
    "center",
    "scorched",
    "ragnarok",
    "aberration",
    "extinction",
    "valguero",
    "genesis1",
    "genesis2",
    "crystal",
    "lost",
    "fjordur"
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