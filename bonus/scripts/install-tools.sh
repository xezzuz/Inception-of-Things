#!/bin/bash
# Installs Docker Engine, K3d, kubectl, and the Argo CD CLI for the bonus VM.

set -euo pipefail

echo "[1/5] Installing required packages (ca-certificates, curl)"
apt-get update
apt-get install -y ca-certificates curl
echo "[1/5] Done (ca-certificates, curl)"

# Install Docker
if ! command -v docker >/dev/null 2>&1; then
  echo "[2/5] Installing Docker"
  curl -fsSL https://get.docker.com | sh
  echo "[2/5] Done (Docker)"
fi
systemctl enable --now docker
usermod -aG docker vagrant

# Install kubectl
if ! command -v kubectl >/dev/null 2>&1; then
  echo "[3/5] Installing kubectl"
  kubectl_version="$(curl -fsSL https://dl.k8s.io/release/stable.txt)"
  curl -fsSLo /tmp/kubectl \
    "https://dl.k8s.io/release/${kubectl_version}/bin/linux/arm64/kubectl"
  install -m 0755 /tmp/kubectl /usr/local/bin/kubectl
  rm -f /tmp/kubectl
  echo "[3/5] Done (kubectl)"
fi

# Install K3d
if ! command -v k3d >/dev/null 2>&1; then
  echo "[4/5] Installing K3d"
  curl -fsSL https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
  echo "[4/5] Done (K3d)"
fi

# Install ArgoCD
if ! command -v argocd >/dev/null 2>&1; then
  echo "[5/5] Installing ArgoCD"
  curl -fsSLo /tmp/argocd \
    https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-arm64
  install -m 0755 /tmp/argocd /usr/local/bin/argocd
  rm -f /tmp/argocd
  echo "[5/5] Done (ArgoCD)"
fi

echo "Installed Docker, K3d, kubectl, and ArgoCD"
