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
  echo "Didn't get exactly one arg, so will delete global things instead. Got: $*"
  echo "Valid server/map names are: islan, cent, scorc, rag, ab, ext, valg, gen1, cryst"
  kubectl delete -f ark-pvc-shared.yaml
  kubectl delete -f ArkManagerCfgCM.yaml
  kubectl delete -f GlobalGameUserSettingsCM.yaml
  kubectl delete -f GlobalGameIniCM.yaml
  kubectl delete -f ArkPlayerListsCM.yaml
  kubectl delete -f ark-server-secrets.yaml
  kubectl delete -f ark-service.yaml
fi
