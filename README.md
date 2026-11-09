# Inception of Things

Inception of Things is a hands-on Kubernetes project that moves from a
two-node K3s cluster to a GitOps workflow managed by Argo CD. Each part is
independent and can be run locally.

## What it covers

- Provisioning VirtualBox VMs with Vagrant
- Building single-node and multi-node K3s clusters
- Routing HTTP traffic with Traefik Ingress
- Running Kubernetes locally with K3d
- Deploying and reconciling applications with Argo CD
- Using a local GitLab instance as a GitOps source

## Requirements

- VirtualBox and Vagrant for Parts 1, 2, and the bonus
- Docker Desktop, Homebrew, and macOS for Part 3

## Projects

| Directory | Description |
| --- | --- |
| [p1](p1/README.md) | Two-node K3s cluster on Vagrant |
| [p2](p2/README.md) | K3s ingress with three routed applications |
| [p3](p3/README.md) | K3d, Argo CD, and GitOps |
| [bonus](bonus/README.md) | Local GitLab-backed GitOps |

## Project flow

```text
Part 1  Vagrant → two-node K3s cluster
Part 2  Vagrant → K3s → Traefik → three applications
Part 3  Docker → K3d → Argo CD → GitOps application
Bonus   Vagrant → GitLab + K3d + Argo CD → local GitOps application
```

## Getting started

Choose a part, enter its directory, and follow its README. For example:

```sh
cd p1
make up
```

Each part includes commands to verify the deployment and remove local
resources when finished.
