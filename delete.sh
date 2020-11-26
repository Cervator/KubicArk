#!/bin/bash
if [ $# -eq 1 ]
then
  echo "Going to delete stuff for the ARK server running $1";
  kubectl delete -f $1/ark-deployment.yaml
  kubectl delete -f $1/ark-pvc.yaml
  kubectl delete -f $1/OverrideGameUserSettingsCM.yaml
  kubectl delete -f $1/OverrideGameIniCM.yaml
  # TODO: Consider using a stateful set just to get a cleaner pod name? Only ever 0 or 1 instances ...
else
  echo "Didn't get exactly one arg, so will delete global things instead. Got $# ! $*"
  echo "Valid server/map names are: islan, cent, scorc, rag, ab, ext, valg, gen1, cryst"
  kubectl apply -f ark-pvc-shared.yaml
  kubectl apply -f ArkManagerCfgCM.yaml
  kubectl apply -f GlobalGameUserSettingsCM.yaml
  kubectl apply -f GlobalGameIniCM.yaml
  kubectl apply -f ArkPlayerListsCM.yaml
  kubectl apply -f ark-server-secrets.yaml
  kubectl apply -f ark-service.yaml
fi
