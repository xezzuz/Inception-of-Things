# Part 1 — K3s Cluster

Creates a two-node K3s cluster in VirtualBox: one server and one agent.

## Run

```sh
cd p1
make up
```

## Verify

```sh
vagrant ssh nazouzS -c 'sudo k3s kubectl get nodes -o wide'
vagrant ssh nazouzS -c 'sudo k3s kubectl get pods -A'
```

Both nodes must be `Ready`. The cluster uses the Vagrant private network
(`192.168.56.0/24`) for inter-node Flannel traffic.

## Stop or remove

```sh
make down
make clean
```
