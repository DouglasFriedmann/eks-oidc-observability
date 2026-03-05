#!/usr/bin/env bash
set -euo pipefail

helm uninstall kube-prometheus-stack -n observability || true
kubectl delete namespace observability || true

