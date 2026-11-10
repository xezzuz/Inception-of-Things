#!/usr/bin/env bash
# Bonus-local copy of the Part 3 K3d setup.

set -euo pipefail

if ! id -nG | grep -qw docker; then
  exec sg docker -c 'exec "$0" "$@"' "$0" "$@"
fi

CLUSTER_NAME="iot-bonus"

if k3d cluster get "$CLUSTER_NAME" >/dev/null 2>&1; then
  echo "K3d cluster '$CLUSTER_NAME' already exists."
else
  k3d cluster create "$CLUSTER_NAME" \
    --servers 1 \
    --agents 0 \
    --api-port '127.0.0.1:6443' \
    --port '8889:80@loadbalancer'
fi

k3d kubeconfig merge "$CLUSTER_NAME" \
  --kubeconfig-merge-default \
  --kubeconfig-switch-context

kubectl wait --for=condition=Ready node --all --timeout=2m
kubectl wait --for=condition=Available deployment --all \
  --namespace kube-system --timeout=2m
