.DEFAULT_GOAL := help

SERVER_NODE := nazouz
WORKER_NODE := hel-magh

token:
	./scripts/generate-k3s-token.sh

up: token
	vagrant up
	vagrant status

down:
	vagrant halt

reload:
	vagrant reload

provision:
	vagrant provision

status:
	vagrant status

validate:
	vagrant validate
	@for script in scripts/*.sh; do bash -n "$$script"; done

ssh-server:
	vagrant ssh $(SERVER_NODE)

ssh-worker:
	vagrant ssh $(WORKER_NODE)

nodes:
	vagrant ssh $(SERVER_NODE) -c 'sudo k3s kubectl get nodes -o wide'

pods:
	vagrant ssh $(SERVER_NODE) -c 'sudo k3s kubectl get pods -A'

clean:
	vagrant destroy -f

fclean: clean
	rm -rf .vagrant
	rm -f shared/node-token

re:
	$(MAKE) fclean
	$(MAKE) up

help:
	@echo "Available targets:"
	@echo "  make up          Generate the K3s token if needed and create both VMs"
	@echo "  make down        Halt both VMs while keeping their disks and token"
	@echo "  make reload      Reload VMs to apply Vagrantfile changes"
	@echo "  make provision   Rerun the bootstrap scripts on existing VMs"
	@echo "  make status      Show Vagrant machine status"
	@echo "  make validate    Validate the Vagrantfile and Bash scripts"
	@echo "  make ssh-server  Open an SSH session on the K3s server"
	@echo "  make ssh-worker  Open an SSH session on the K3s worker"
	@echo "  make nodes       Show Kubernetes nodes"
	@echo "  make pods        Show pods in every namespace"
	@echo "  make clean       Destroy both VMs but keep the token"
	@echo "  make fclean      Destroy VMs and remove all local Vagrant state and the token"
	@echo "  make re          Fully rebuild the cluster with a new token"

.PHONY: help token up down reload provision status validate ssh-server ssh-worker nodes pods clean fclean re
