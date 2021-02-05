#!/bin/bash
kubectl apply -k sealed-secrets/
kubectl apply -f ~/master.key
kubectl delete pod -n kube-system -l name=sealed-secrets-controller
kustomize build argocd/ | kubectl apply -f -
kubectl apply -f app-of-apps.yaml
