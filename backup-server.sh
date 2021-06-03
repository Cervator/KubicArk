#!/bin/bash
export targetns=ark
if [ $# -eq 1 ]
then
  echo "Going to back up the ARK map $1 giving it 30 seconds to get far enough for a file to be ready";
  #kubectl delete -f $1/backup-job.yaml -n ark
  kubectl get jobs -n ark
  kubectl apply -f $1/backup-job.yaml -n ark
  kubectl get jobs -n ark
  sleep 30
  kubectl get jobs -n ark
  pod=$(kubectl get pods -n ark --selector=job-name=ark${1}backup --output=jsonpath='{.items[*].metadata.name}')
  echo $pod
  kubectl cp ark/$pod:/ark/server/ShooterGame/Saved/SavedArks/${1}_backup.tar.gz ${1}_backup.tar.gz
  ls -la
else
  echo "Didn't get exactly one arg, so won't try to back anything up: $*"
  echo "Valid short server/map names are: islan, cent, scorc, rag, ab, ext, valg, gen1, cryst"
fi
