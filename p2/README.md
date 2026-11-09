# Part 2 — K3s Ingress

Creates a single-node K3s cluster with Traefik ingress and three applications.

## Run

```sh
cd p2
make up
```

## Verify

```sh
curl -H 'Host: app1.com' http://192.168.56.110/
curl -H 'Host: app2.com' http://192.168.56.110/
curl http://192.168.56.110/
```

The first two requests route to apps one and two; the request without a host
header uses the third application.

## Stop or remove

```sh
make down
make clean
```
