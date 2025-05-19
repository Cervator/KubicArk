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

  saves_path=/ark/server/ShooterGame/Saved/SavedArks
  backup_file="${server_name}_backup.tar.gz"
  pod_name="ark${server_name}-0"

  # Check if the pod exists
  kubectl get pod ${pod_name} -n ark > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "Error: Pod ${pod_name} not found."
    exit 1
  fi

  # Delete the old backup file on the server then create a new one full of various ARK goodies
  kubectl exec -it ${pod_name} -n ark -- sh -c "
    rm -f ${saves_path}/${backup_file};
    find ${saves_path} \( -name ${ark_file} -o -name '*.arkprofile' -o -name '*.arktribe' -o -name ServerPaintingsCache \) -print0 | sed -z 's,^./,,g' | tar cfz ${saves_path}/${backup_file} -C ${saves_path} -T -;
  "

  # Copy the backup file to the local directory
  kubectl cp ${pod_name}:${saves_path}/${backup_file} ${backup_file} -n ark

  echo "Backup complete: ${backup_file}"
                            
  # Get the current timestamp to use in the bucket folder hierarchy
  timestamp=$(date +%Y%m%d-%H%M%S)

  gsutil cp ${backup_file} gs://kubic-game-hosting/ark/${server_name}/${timestamp}/${backup_file}

  echo "Backup uploaded! Should be available at https://storage.googleapis.com/kubic-game-hosting/ark/${server_name}/${timestamp}/${backup_file}"

else
  echo "Didn't get exactly one arg, so won't try to back anything up: $*"
  echo "See the list inside this shell script for the supported servers"
fi
