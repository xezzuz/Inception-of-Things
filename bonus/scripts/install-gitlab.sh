#!/bin/bash
# Installs and configures GitLab CE for the bonus VM.

set -euo pipefail

GITLAB_HOST="192.168.56.120"

if [[ "$(id -u)" -ne 0 ]]; then
  echo "This script must run as root." >&2
  exit 1
fi

echo "[1/3] Installing required packages (curl, ca-certificates, tzdata, perl)"
apt-get update
apt-get install -y curl ca-certificates tzdata perl
echo "[1/3] Done (curl, ca-certificates, tzdata, perl)"

if ! command -v gitlab-ctl >/dev/null 2>&1; then
  echo "[2/3] Installing GitLab CE"
  # Add the official GitLab CE repository
  curl -fsSL \
    https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh \
    | bash

  # Install GitLab
  EXTERNAL_URL="http://${GITLAB_HOST}" \
    apt-get install -y gitlab-ce
  echo "[2/3] Done (GitLab CE)"
fi

echo "[3/3] Configuring GitLab"
gitlab_config="/etc/gitlab/gitlab.rb"
if grep -q '^external_url ' "$gitlab_config"; then
  sed -i "s|^external_url .*|external_url 'http://${GITLAB_HOST}'|" "$gitlab_config"
else
  printf "external_url 'http://%s'\n" "$GITLAB_HOST" >>"$gitlab_config"
fi
gitlab-ctl reconfigure
echo "[3/3] Done (GitLab)"

echo "GitLab is available at http://${GITLAB_HOST}."
echo "Its initial root password is in /etc/gitlab/initial_root_password."
