#!/bin/bash
# Creates and seeds the local GitLab project once. GitLab remains the source
# of truth after the first successful provision.

# Stop on command errors, unset variables, and failed commands in pipelines.
set -euo pipefail

# GitLab listens locally during provisioning. The Vagrant IP is only needed by
# Argo CD later, when it clones the repository from inside the K3d cluster.
GITLAB_HEALTH_URL="http://127.0.0.1"
# The public GitLab project that Argo CD watches.
PROJECT_PATH="root/iot-gitops-nazouz"
PROJECT_NAME="iot-gitops-nazouz"
# The four Kubernetes files that form the initial GitOps repository contents.
MANIFEST_DIR="/vagrant/confs/dev"
MANIFESTS=(deployment.yaml ingress.yaml namespace.yaml service.yaml)

# Vagrant runs this provisioner as root. GitLab's administrative runner and
# the GitLab files it accesses require that privilege.
if [[ "$(id -u)" -ne 0 ]]; then
  echo "This script must run as root." >&2
  exit 1
fi

# Check prerequisites early so a missing command produces a direct error.
for command in curl gitlab-rails; do
  if ! command -v "$command" >/dev/null 2>&1; then
    echo "Missing command: $command" >&2
    exit 1
  fi
done

# Do not create a half-seeded repository if a required local manifest is
# missing from the Vagrant shared directory.
for manifest in "${MANIFESTS[@]}"; do
  if [[ ! -f "${MANIFEST_DIR}/${manifest}" ]]; then
    echo "Missing manifest: ${manifest}" >&2
    exit 1
  fi
done

# Installing and reconfiguring the package does not guarantee that every
# GitLab service is ready yet. Repository creation needs all of them.
echo "Waiting for GitLab..."
for attempt in $(seq 1 120); do
  if curl --fail --silent --show-error --max-time 5 \
    "${GITLAB_HEALTH_URL}/-/readiness?all=1" >/dev/null; then
    break
  fi

  if [[ "$attempt" -eq 120 ]]; then
    echo "GitLab was not ready after 10 minutes." >&2
    exit 1
  fi

  sleep 5
done

# Execute Ruby inside the local GitLab installation. This avoids creating a
# temporary API token, cloning a repository, and pushing through Git.
#
# gitlab-rails launches Rails through the Omnibus environment and does not
# preserve arbitrary variables exported by this provisioner. Keep the fixed,
# non-secret bootstrap settings in the runner program itself rather than
# reading them from ENV.
gitlab-rails runner -e production '
  project_path = "root/iot-gitops-nazouz"
  project_name = "iot-gitops-nazouz"
  manifest_dir = "/vagrant/confs/dev"
  manifests = %w[deployment.yaml ingress.yaml namespace.yaml service.yaml]

  # GitLab projects must have an owning user. The locally installed instance
  # always creates the root administrator during initial configuration.
  user = User.find_by_username!("root")

  project = Project.find_by_full_path(project_path)
  if project
    puts "GitOps repository #{project.full_path} already exists; leaving it unchanged."
    exit
  end

  # Create a public project in the root user personal namespace. The README
  # creates the first commit and therefore establishes the default branch.
  project = Projects::CreateService.new(
    user,
    {
      name: project_name,
      path: project_name,
      visibility_level: Gitlab::VisibilityLevel::PUBLIC,
      initialize_with_readme: true
    }
  ).execute

  # Surface GitLab validation failures as a useful provisioning error.
  raise project.errors.full_messages.join(", ") unless project.persisted?

  # The default branch may not always be named main, so use the GitLab value.
  branch = project.default_branch
  raise "GitLab project has no default branch." if branch.nil?

  repository = project.repository

  # The project is new, so create all four validated manifests in one commit.
  actions = manifests.map do |filename|
    {
      action: :create,
      file_path: filename,
      content: File.read(File.join(manifest_dir, filename))
    }
  end

  # Commit every manifest together on the repository default branch.
  repository.commit_files(
    user,
    branch_name: branch,
    message: "seed Argo CD manifests",
    actions: actions
  )
  puts "Created and seeded GitOps repository #{project.full_path}."
'
