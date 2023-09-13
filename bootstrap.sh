#!/bin/bash
op connect server create k8s
base64 -w 0 1password-credentials.json > 1password-credentials.json.b64
rm 1password-credentials.json && mv 1password-credentials.json.b64 1password-credentials.json
kubectl apply -f 1password/templates/namespace.yaml
kubectl create secret generic op-credentials --from-file=1password-credentials.json --from-literal=token=$(op connect token create op-k8s-operator --server k8s --vault k8s,r) --namespace=onepassword --dry-run=client -o yaml | kubectl apply -f -
kubectl create secret generic onepassword-connect-token --from-literal=token=$(op connect token create external-secrets --server k8s --vault k8s,r) --namespace=kube-system --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -k sealed-secrets/
kubectl apply -f ~/master.key
kubectl delete pod -n kube-system -l name=sealed-secrets-controller
kustomize build argocd/ | kubectl apply -f -
kubectl apply -f app-of-apps.yaml
