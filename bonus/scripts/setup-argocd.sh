#!/usr/bin/env bash
# Bonus-local copy of the Part 3 Argo CD setup.

set -euo pipefail

EXPECTED_CONTEXT="k3d-iot-bonus"
ARGOCD_VERSION="v3.6.0"
ARGOCD_NAMESPACE="argocd"
MANIFEST_URL="https://raw.githubusercontent.com/argoproj/argo-cd/$ARGOCD_VERSION/manifests/install.yaml"
APPLICATION_MANIFEST="/vagrant/confs/argocd/application.yaml"

if [[ "$(kubectl config current-context)" != "$EXPECTED_CONTEXT" ]]; then
  echo "The active kubectl context must be $EXPECTED_CONTEXT." >&2
  exit 1
fi

kubectl create namespace "$ARGOCD_NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
# GitLab is installed on the VM for this bonus, but retain the namespace the
# exercise reserves for it so the cluster layout remains explicit.
kubectl create namespace gitlab --dry-run=client -o yaml | kubectl apply -f -
kubectl apply --server-side --force-conflicts --namespace "$ARGOCD_NAMESPACE" \
  --filename "$MANIFEST_URL"
kubectl rollout status deployment --namespace "$ARGOCD_NAMESPACE" --timeout=5m
kubectl rollout status statefulset --namespace "$ARGOCD_NAMESPACE" --timeout=5m
[[ -f "$APPLICATION_MANIFEST" ]] || {
  echo "Missing Argo CD Application manifest: $APPLICATION_MANIFEST" >&2
  exit 1
}
kubectl apply -f "$APPLICATION_MANIFEST"
