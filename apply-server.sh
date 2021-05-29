#!/bin/bash
export targetns=ark
if [ $# -eq 1 ]
then
  echo "Going to work with the ARK server running $1";
  kubectl create namespace $targetns
  kubectl apply -f $1/ark-pvc.yaml -n $targetns
  kubectl apply -f ark-pvc-shared.yaml -n $targetns
  kubectl apply -f ArkManagerCfgCM.yaml -n $targetns
  kubectl apply -f GlobalGameUserSettingsCM.yaml -n $targetns
  kubectl apply -f $1/OverrideGameUserSettingsCM.yaml -n $targetns
  kubectl apply -f GlobalGameIniCM.yaml -n $targetns
  kubectl apply -f $1/OverrideGameIniCM.yaml -n $targetns
  kubectl apply -f ArkPlayerListsCM.yaml -n $targetns
  echo "Hope you remembered to update the passwords in the secrets file only locally!"
  kubectl apply -f ark-server-secrets.yaml -n $targetns
  kubectl apply -f $1/ark-service.yaml -n $targetns
  kubectl apply -f $1/ark-deployment.yaml -n $targetns
  # TODO: Consider using a stateful set just to get a cleaner pod name? Only ever 0 or 1 instances ...
else
  echo "Didn't get exactly one arg, got $# ! $*"
  echo "Valid server/map names are: islan, cent, scorc, rag, ab, ext, valg, gen1, cryst"
fi
