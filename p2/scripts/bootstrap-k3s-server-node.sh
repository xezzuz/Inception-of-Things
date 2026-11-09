#!/bin/bash
# Exit on command failures, unset variables, and failed pipelines.
set -euo pipefail

# The Part 2 K3s server listens on the VM's private-network address.
SERVER_IP="192.168.56.110"

# The K3s installer is downloaded with curl; install it on minimal Debian images.
if ! command -v curl >/dev/null 2>&1; then
  echo "Installing curl..."
  apt-get update
  apt-get install -y curl
fi

# Install and start the control-plane node
echo "Installing K3s server..."
curl -sfL https://get.k3s.io | \
	sh -s - server --node-ip "$SERVER_IP" --flannel-iface enp0s9

echo "Waiting for K3s to become reachable..."
until /usr/local/bin/k3s kubectl get nodes >/dev/null 2>&1; do
  sleep 2
done

echo "Applying Part 2 manifests..."
/usr/local/bin/k3s kubectl apply -R -f /vagrant/confs/

echo "K3s server and Part 2 workloads are ready"
