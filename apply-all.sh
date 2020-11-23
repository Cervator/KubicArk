kubectl apply -f ark-pvc.yaml
kubectl apply -f ark-pvc-shared.yaml
kubectl apply -f ArkManagerCfgCM.yaml
kubectl apply -f GlobalGameUserSettingsCM.yaml
kubectl apply -f OverrideGameUserSettingsCM.yaml
kubectl apply -f GlobalGameIniCM.yaml
kubectl apply -f OverrideGameIniCM.yaml
kubectl apply -f ArkPlayerListsCM.yaml
echo "Hope you remembered to update the passwords in the secrets file only locally!"
kubectl apply -f ark-server-secrets.yaml
kubectl apply -f ark-service.yaml
kubectl apply -f ark-deployment.yaml
