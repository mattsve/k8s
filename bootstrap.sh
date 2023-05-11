#!/bin/bash
op connect server create k8s
op connect token create k8s-token --server k8s --vaults k8s,r > k8s-token.txt 
kubectl apply -f 1password/templates/namespace.yaml
kubectl create secret generic op-credentials --from-file=1password-credentials.json --from-file=token=./k8s-token.txt --namespace=1password --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -k sealed-secrets/
kubectl apply -f ~/master.key
kubectl delete pod -n kube-system -l name=sealed-secrets-controller
kustomize build argocd/ | kubectl apply -f -
kubectl apply -f app-of-apps.yaml
