#!/bin/bash
# Requires Homebrew and Docker Desktop
# Installs K3d, kubectl and ArgoCD

set -euo pipefail

require_macos() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "This installer supports macOS only; detected: $(uname -s)." >&2
    exit 1
  fi
}

require_homebrew() {
  if ! command -v brew >/dev/null 2>&1; then
    cat >&2 <<'EOF'
Homebrew is required to install the Part 3 command-line tools.
Install it from https://brew.sh/, open a new terminal, then rerun this script.
EOF
    exit 1
  fi
}

install_formula() {
  local formula="$1"

  if command -v "$formula" >/dev/null 2>&1; then
    echo "$formula is already installed."
    return
  fi

  echo "Installing $formula with Homebrew..."
  brew install "$formula"
}

require_docker_desktop() {
  if ! command -v docker >/dev/null 2>&1; then
    cat >&2 <<'EOF'
Docker Desktop is required but the docker command was not found.
Install and start Docker Desktop for Mac from:
https://docs.docker.com/desktop/setup/install/mac-install/
Then rerun this script.
EOF
    exit 1
  fi

  if ! docker info >/dev/null 2>&1; then
    cat >&2 <<'EOF'
The Docker command is installed, but the Docker daemon is not available.
Start Docker Desktop, wait until it reports that it is running, then rerun this script.
EOF
    exit 1
  fi
}

require_macos
require_homebrew
require_docker_desktop

install_formula k3d
install_formula kubectl
install_formula argocd

echo
echo "Part 3 tooling is ready:"
docker --version
docker info --format 'Docker daemon: {{.ServerVersion}}'
k3d version
kubectl version --client
argocd version --client
