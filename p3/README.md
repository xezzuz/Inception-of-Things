# Part 3 — Argo CD GitOps

Creates a local K3d cluster and deploys the `playground-dev` application with
Argo CD from its Git repository.

## Requirements

macOS with Docker Desktop running and Homebrew installed.

## Run

```sh
cd p3
make install
make up
make verify
```

The application is available at [http://127.0.0.1:8888](http://127.0.0.1:8888).

## Verify GitOps

Update the image tag in the tracked GitOps repository and push the change to
`main`. Argo CD automatically syncs the `dev` workload.

```sh
make status
make verify
```

## Stop or remove

```sh
make down
make clean
```
