kubectl delete -f ark-deployment.yaml
kubectl delete -f ArkManagerCfgCM.yaml
kubectl delete -f GlobalGameUserSettingsCM.yaml
kubectl delete -f OverrideGameUserSettingsCM.yaml
kubectl delete -f ArkPlayerListsCM.yaml
kubectl delete -f ark-service.yaml
kubectl delete -f ark-pvc.yaml
kubectl delete -f ark-pvc-shared.yaml
