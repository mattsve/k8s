#!/bin/bash
op connect server create k8s
base64 -w 0 1password-credentials.json > 1password-credentials.json.b64
rm 1password-credentials.json && mv 1password-credentials.json.b64 1password-credentials.json
kubectl apply -f 1password/templates/namespace.yaml
kubectl create secret generic op-credentials --from-file=1password-credentials.json --from-literal=token=$(op create connect token k8s op-k8s-operator --vault k8s,r) --namespace=1password --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -k sealed-secrets/
kubectl apply -f ~/master.key
kubectl delete pod -n kube-system -l name=sealed-secrets-controller
kustomize build argocd/ | kubectl apply -f -
kubectl apply -f app-of-apps.yaml
