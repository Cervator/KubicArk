#!/bin/bash
export targetns=ark
if [ $# -eq 1 ]
then
  echo "Going to create and start the ARK server running the $1 map";
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
  kubectl apply -f $1/ark-statefulset.yaml -n $targetns
else
  echo "Didn't get exactly one arg, got $# ! $*"
  echo "Valid short server/map names are: islan, cent, scorc, rag, ab, ext, valg, gen1, cryst, lost, fjordur"
fi
