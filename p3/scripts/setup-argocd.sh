#!/bin/bash
# Installs a pinned, non-HA Argo CD release into the local K3d cluster.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXPECTED_CONTEXT="k3d-iot-p3"
ARGOCD_VERSION="v3.6.0"
ARGOCD_NAMESPACE="argocd"
MANIFEST_URL="https://raw.githubusercontent.com/argoproj/argo-cd/$ARGOCD_VERSION/manifests/install.yaml"

if [[ "$(kubectl config current-context)" != "$EXPECTED_CONTEXT" ]]; then
  echo "The active kubectl context must be $EXPECTED_CONTEXT." >&2
  echo "Run ./p3/scripts/setup-cluster.sh first." >&2
  exit 1
fi

# Generate namespace config and apply it (Idempotent).
kubectl create namespace "$ARGOCD_NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -

# According to ArgoCD Official Docs: https://argo-cd.readthedocs.io/en/stable/getting_started/#1-install-argo-cd
kubectl apply --server-side --force-conflicts \
  --namespace "$ARGOCD_NAMESPACE" \
  --filename "$MANIFEST_URL"

echo "Waiting for Argo CD to become ready..."
# Wait for all Argo CD Deployment replicas to be updated and available.
kubectl rollout status deployment \
  --namespace "$ARGOCD_NAMESPACE" \
  --timeout=5m
# Wait for the application controller's StatefulSet Pods to be updated and Ready.
kubectl rollout status statefulset \
  --namespace "$ARGOCD_NAMESPACE" \
  --timeout=5m

# Register the GitOps source; Argo CD then deploys playground from Git.
kubectl apply -f "$SCRIPT_DIR/../confs/argocd/application.yaml"

echo
kubectl get pods -n "$ARGOCD_NAMESPACE"
echo
echo "Argo CD is installed and playground-dev is registered for automatic sync."
echo "Its web interface is not exposed yet."
