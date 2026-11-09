# Bonus — Local GitLab GitOps

Creates a VirtualBox VM running GitLab, K3d, Argo CD, and the `playground-dev`
application.

## Run

```sh
cd bonus
make up
```

GitLab is available at [http://192.168.56.120](http://192.168.56.120). Sign in
as `root`; retrieve the initial password with:

```sh
make gitlab-password
```

## Verify

```sh
make verify
curl http://192.168.56.120:8889/
```

GitLab seeds `root/iot-gitops-nazouz`. Change the image tag in its
`deployment.yaml`, commit it, then run `make verify` to confirm Argo CD synced
the deployment.

## Stop or remove

```sh
make down
make clean
```
