#!/bin/bash
if [ $# -eq 1 ]
then
  echo "Going to work with the ARK server running $1";
  kubectl apply -f $1/ark-pvc.yaml
  kubectl apply -f ark-pvc-shared.yaml
  kubectl apply -f ArkManagerCfgCM.yaml
  kubectl apply -f GlobalGameUserSettingsCM.yaml
  kubectl apply -f $1/OverrideGameUserSettingsCM.yaml
  kubectl apply -f GlobalGameIniCM.yaml
  kubectl apply -f $1/OverrideGameIniCM.yaml
  kubectl apply -f ArkPlayerListsCM.yaml
  echo "Hope you remembered to update the passwords in the secrets file only locally!"
  kubectl apply -f ark-server-secrets.yaml
  kubectl apply -f $1/ark-service.yaml
  kubectl apply -f $1/ark-deployment.yaml
  # TODO: Consider using a stateful set just to get a cleaner pod name? Only ever 0 or 1 instances ...
else
  echo "Didn't get exactly one arg, got $# ! $*"
  echo "Valid server/map names are: islan, cent, scorc, rag, ab, ext, valg, gen1, cryst"
fi
