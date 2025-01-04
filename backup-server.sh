# New approach
# Jenkins calls this script from server-specific jobs that get the server name from its parent folder and passes it in here
# kubectl go delete old zip on server if there
# kubectl run the zip process
# kubectl cp that file locally
# gcloud upload that file to a bucket

#!/bin/bash
server_name=$1

# Function to get the .ark file name for a server (avoids using an array in case of unsupportive shells)
get_ark_file() {
  local server_name=$1

  if [ "$server_name" = "island" ]; then
    echo "island.ark"
  elif [ "$server_name" = "center" ]; then
    echo "center.ark"
  elif [ "$server_name" = "scorched" ]; then
    echo "scorched.ark"
  elif [ "$server_name" = "ragnarok" ]; then
    echo "ragnarok.ark"
  elif [ "$server_name" = "aberration" ]; then
    echo "aberration.ark"
  elif [ "$server_name" = "extinction" ]; then
    echo "extinction.ark"
  elif [ "$server_name" = "valguero" ]; then
    echo "Valguero_P.ark"
  elif [ "$server_name" = "genesis1" ]; then
    echo "Genesis.ark"
  elif [ "$server_name" = "genesis2" ]; then
    echo "Gen2.ark"
  elif [ "$server_name" = "crystal" ]; then
    echo "crystal.ark"
  elif [ "$server_name" = "lost" ]; then
    echo "LostIsland.ark"
  elif [ "$server_name" = "fjordur" ]; then
    echo "Fjordur.ark"
  else
    echo "Unknown server: $server_name"
    return 1 # Indicate an error
  fi
}

if [ $# -eq 1 ]
then
  ark_file=$(get_ark_file "$server_name")

  # Check if the function returned an error
  if [ $? -ne 0 ]; then
    echo "Error getting ark file name."
    exit 1
  fi

  echo "$server_name uses the ark file name: $ark_file"

  kubectl get ns

  # Execute the backup command
  #kubectl exec -it "$pod_name" -n "$namespace" -- sh -c "$backup_command"

  # Copy the backup file
  #kubectl cp "$pod_name":"$backup_file" "$backup_file" -c <container-name> -n "$namespace"
                            
  # Get the current timestamp to use in the bucket folder hierarchy
  timestamp=$(date +%Y%m%d-%H%M%S)

  echo "This is a test file from Jenkins." > backup.txt

  gsutil cp backup.txt gs://kubic-game-hosting/ark/${server_name}/${timestamp}/backup.txt

else
  echo "Didn't get exactly one arg, so won't try to back anything up: $*"
  echo "See the list inside this shell script for the supported servers"
fi
