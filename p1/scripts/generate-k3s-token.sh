#!/bin/bash
# Create the shared K3s join token before running `vagrant up`.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PART_1_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
TOKEN_PATH="$PART_1_DIR/shared/node-token"

# Keep an existing token so reprovisioning and additional workers join the same cluster.
if [ -s "$TOKEN_PATH" ]; then
    echo "K3s token already exists at $TOKEN_PATH"
    exit 0
fi

mkdir -p "$(dirname "$TOKEN_PATH")"
openssl rand -hex 32 > "$TOKEN_PATH"

echo "Created K3s token at $TOKEN_PATH"
