#!/bin/bash
export targetns=ark
if [ $# -eq 1 ]
then
  echo "Going to back up the ARK map $1 giving it 30 seconds to get far enough for a file to be ready";
  kubectl get jobs -n ark
  kubectl delete -f $1/backup-job.yaml -n ark --ignore-not-found=true
  sleep 5
  echo "Deleted old job, if present"
  kubectl get jobs -n ark
  kubectl apply -f $1/backup-job.yaml -n ark
  kubectl get jobs -n ark
  sleep 30
  echo "Slept 30 secs, job should not be finished yet, so we can do the copy before it exits"
  kubectl get jobs -n ark
  pod=$(kubectl get pods -n ark --selector=job-name=ark${1}backup --output=jsonpath='{.items[*].metadata.name}')
  echo "Job pod to target is: $pod"
  kubectl cp ark/$pod:/ark/server/ShooterGame/Saved/SavedArks/${1}_backup.tar.gz ${1}_backup.tar.gz
  ls -la
else
  echo "Didn't get exactly one arg, so won't try to back anything up: $*"
  echo "Valid short server/map names are: islan, cent, scorc, rag, ab, ext, valg, gen1, cryst, lost, fjordur"
fi
