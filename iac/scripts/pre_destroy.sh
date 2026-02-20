#!/usr/bin/env bash
set -euo pipefail

NAMESPACE_OBS="${NAMESPACE_OBS:-observability}"
NAMESPACE_APP="${NAMESPACE_APP:-app}"

echo "Deleting app + observability resources that create AWS LBs / EBS volumes..."

# If using Helm later:
# helm uninstall kube-prometheus-stack -n "$NAMESPACE_OBS" || true
# helm uninstall loki -n "$NAMESPACE_OBS" || true
# helm uninstall app -n "$NAMESPACE_APP" || true

# If using raw manifests later:
kubectl delete ingress --all -n "$NAMESPACE_APP" || true
kubectl delete svc --all -n "$NAMESPACE_APP" || true

kubectl delete pvc --all -n "$NAMESPACE_OBS" || true

echo "Done. Give AWS a minute to delete load balancers."

