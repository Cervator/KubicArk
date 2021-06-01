#!/bin/bash
export targetns=ark
echo "Going to delete the namespace $targetns and the auth pieces for a service user"
kubectl delete namespace $targetns
kubectl delete -f auth
