#!/bin/bash

set -euo pipefail

CLUSTER_NAME="iot-p3"

# Creating K8s cluster if it doesn't exist.
if k3d cluster get "$CLUSTER_NAME" >/dev/null 2>&1; then
  echo "K3d cluster '$CLUSTER_NAME' already exists."
else
  k3d cluster create "$CLUSTER_NAME" \
    --servers 1 \
    --agents 0 \
    --api-port '127.0.0.1:6443' \
    --port '8888:80@loadbalancer'
  echo "K3d cluster '$CLUSTER_NAME' created."
fi

# K3d normally does this at creation time.
# Doing it explicitly will let a rerun repairs
# a missing context without recreating the cluster.
echo "Merging $CLUSTER_NAME kubeconfig in default ~/.kube/config and switching to context k3d-$CLUSTER_NAME."
k3d kubeconfig merge "$CLUSTER_NAME" \
  --kubeconfig-merge-default \
  --kubeconfig-switch-context
echo

echo "Waiting for the Kubernetes node and system services..."
# Node Ready: kubelet reports node's condition to K8s; container runtime, networking, etc.
kubectl wait --for=condition=Ready node --all --timeout=2m
# Deployment Available: Minimum Pods threshold of deployment replicas is met.
kubectl wait --for=condition=Available deployment --all \
  --namespace kube-system \
  --timeout=2m

echo
echo "Cluster verification:"
k3d cluster list
kubectl config current-context
kubectl get nodes -o wide
kubectl get pods -A
