# New approach
# Jenkins calls this script from server-specific jobs that get the server name from its parent folder and passes it in here
# kubectl go delete old zip on server if there
# kubectl run the zip process
# kubectl cp that file locally
# gcloud upload that file to a bucket

#!/bin/bash

# Map of server names to their .ark file names
server_maps=(
  "island=island.ark"
  "center=center.ark"
  "scorched=scorched.ark"
  "ragnarok=ragnarok.ark"
  "aberration=aberration.ark"
  "extinction=extinction.ark"
  "valguero=Valguero_P.ark"
  "genesis1=Genesis.ark"
  "genesis2=Gen2.ark"
  "crystal=crystal.ark"
  "lost=LostIsland.ark"
  "fjordur=Fjordur.ark"
)

if [ $# -eq 1 ]
then

  # Get the server name from the command-line argument
  server_name=$1

  # Find the element in the array that matches the server name
  for entry in "${server_maps[@]}"; do
    key=$(echo "$entry" | cut -d '=' -f 1)
    if [ "$key" = "$server_name" ]; then
      ark_file=$(echo "$entry" | cut -d '=' -f 2)
      break
    fi
  done

  # Print the .ark file name for debugging
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
