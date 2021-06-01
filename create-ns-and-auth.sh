#!/bin/bash
export targetns=ark
echo "Going to create the namespace $targetns and the auth pieces for a service user"
kubectl create namespace $targetns
kubectl apply -f auth
kubectl describe sa ark-user -n ark
