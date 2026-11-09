#!/bin/bash
# Exit on command failures, unset variables, and failed pipelines.
set -euo pipefail

# The agent joins the server at this private-network address using the shared token.
SERVER_IP="192.168.56.110"
WORKER_IP="192.168.56.111"
TOKEN_PATH="/vagrant/shared/node-token"

# Do not reinstall an agent that is already running during reprovisioning.
if systemctl is-active --quiet k3s-agent; then
  	echo "K3s agent is already running"
	exit 0
fi

# The K3s installer is downloaded with curl; install it on minimal Debian images.
if ! command -v curl >/dev/null 2>&1; then
  	echo "Installing curl..."
	apt-get update
	apt-get install -y curl
fi

# The token must already exist on the host before Vagrant rsyncs this folder.
if [ ! -s "$TOKEN_PATH" ]; then
	echo "K3s token is missing. Run ./scripts/generate-k3s-token.sh before vagrant up." >&2
	exit 1
fi

TOKEN=$(cat "$TOKEN_PATH")

# Install and start this VM as an agent connected to the K3s server.
echo "Joining K3s server..."
curl -sfL https://get.k3s.io | \
	K3S_URL="https://$SERVER_IP:6443" \
	K3S_TOKEN="$TOKEN" \
	sh -s - agent --node-ip "$WORKER_IP" --flannel-iface enp0s9

echo "K3s agent joined successfully"
