# New approach
# Jenkins calls this script from server-specific jobs that get the server name from its parent folder and passes it in here
# kubectl go delete old zip on server if there
# kubectl run the zip process
# kubectl cp that file locally
# gcloud upload that file to a bucket

#!/bin/bash

# Map of server names to their .ark file names
declare -A server_maps=(
  ["island"]="island.ark"
  ["center"]="center.ark"
  ["scorched"]="scorched.ark"
  ["ragnarok"]="ragnarok.ark"
  ["aberration"]="aberration.ark"
  ["extinction"]="extinction.ark"
  ["valguero"]="Valguero_P.ark"
  ["genesis1"]="Genesis.ark"
  ["genesis2"]="Gen2.ark"
  ["crystal"]="crystal.ark"
  ["lost"]="LostIsland.ark"
  ["fjordur"]="Fjordur.ark"
)

if [ $# -eq 1 ]
then

  # Get the server name from the command-line argument
  server_name=$1

  # Print the .ark file name for debugging
  echo "$server_name uses the ark file name: ${server_maps[$server_name]}" 

  # Execute the backup command
  kubectl get ns
  #kubectl exec -it "$pod_name" -n "$namespace" -- sh -c "$backup_command"

  # Copy the backup file
  #kubectl cp "$pod_name":"$backup_file" "$backup_file" -c <container-name> -n "$namespace"

else
  echo "Didn't get exactly one arg, so won't try to back anything up: $*"
  echo "See the list inside this shell script for the supported servers"
fi
