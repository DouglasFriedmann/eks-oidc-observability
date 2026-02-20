#!/usr/bin/env bash
set -euo pipefail

kubectl apply -f k8s/observability-namespace.yaml

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  -n observability \
  -f k8s/helm/kube-prometheus-stack-values.yaml

