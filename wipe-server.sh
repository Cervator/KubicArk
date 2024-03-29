#!/bin/bash
export targetns=ark
if [ $# -eq 1 ]
then
  echo "Going to stop & destroy the server running the ARK map $1, and WIPE the saved world";
  kubectl delete -f $1/ark-statefulset.yaml -n $targetns
  kubectl delete -f $1/ark-pvc.yaml -n $targetns
  kubectl delete -f $1/OverrideGameUserSettingsCM.yaml -n $targetns
  kubectl delete -f $1/OverrideGameIniCM.yaml -n $targetns
  kubectl delete -f $1/ark-service.yaml -n $targetns
else
  echo "Didn't get exactly one arg, so will delete global things instead and WIPE the cluster save. Got: $*"
  echo "Valid short server/map names are: islan, cent, scorc, rag, ab, ext, valg, gen1, cryst, lost, fjordur"
  kubectl delete -f ark-pvc-shared.yaml -n $targetns
  kubectl delete -f ArkManagerCfgCM.yaml -n $targetns
  kubectl delete -f GlobalGameUserSettingsCM.yaml -n $targetns
  kubectl delete -f GlobalGameIniCM.yaml -n $targetns
  kubectl delete -f ArkPlayerListsCM.yaml -n $targetns
  kubectl delete -f ark-server-secrets.yaml -n $targetns
fi
