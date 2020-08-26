#!/bin/bash
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.12.5/controller.yaml
kubectl apply -f ~/master.key
kubectl delete pod -n kube-system -l name=sealed-secrets-controller
kubectl apply -k argocd/
kubectl apply -f app-of-apps.yaml
