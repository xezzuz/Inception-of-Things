#!/bin/bash
# Exit on command failures, unset variables, and failed pipelines.
set -euo pipefail

# This token is created on the host before `vagrant up` and rsynced into both VMs.
SERVER_IP="192.168.56.110"
TOKEN_PATH="/vagrant/shared/node-token"

# The K3s installer is downloaded with curl; install it on minimal Debian images.
if ! command -v curl >/dev/null 2>&1; then
  	echo "Installing curl..."
	apt-get update
	apt-get install -y curl
fi

# Stop early when the host-side token generator was not run.
if [ ! -s "$TOKEN_PATH" ]; then
	echo "K3s token is missing. Run ./scripts/generate-k3s-token.sh before vagrant up." >&2
	exit 1
fi

TOKEN=$(cat "$TOKEN_PATH")

# Install and start the control-plane node with the token agents will use to join.
echo "Installing K3s server..."
curl -sfL https://get.k3s.io | \
	K3S_TOKEN="$TOKEN" \
	sh -s - server --node-ip "$SERVER_IP" --flannel-iface enp0s9

echo "K3s server is ready"
