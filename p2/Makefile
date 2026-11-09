.DEFAULT_GOAL := help

SERVER_NODE := nazouz

up:
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

nodes:
	vagrant ssh $(SERVER_NODE) -c 'sudo k3s kubectl get nodes -o wide'

pods:
	vagrant ssh $(SERVER_NODE) -c 'sudo k3s kubectl get pods -A'

clean:
	vagrant destroy -f

fclean: clean
	rm -rf .vagrant

re:
	$(MAKE) fclean
	$(MAKE) up

help:
	@echo "Available targets:"
	@echo "  make up          Create the Part 2 VM and deploy the workloads"
	@echo "  make down        Halt the VM while keeping its disk"
	@echo "  make reload      Reload the VM to apply Vagrantfile changes"
	@echo "  make provision   Rerun the K3s and workload bootstrap script"
	@echo "  make status      Show the Vagrant machine status"
	@echo "  make validate    Validate the Vagrantfile and Bash scripts"
	@echo "  make ssh-server  Open an SSH session on the K3s server"
	@echo "  make nodes       Show Kubernetes nodes"
	@echo "  make pods        Show pods in every namespace"
	@echo "  make clean       Destroy the VM but keep local Vagrant state"
	@echo "  make fclean      Destroy the VM and remove local Vagrant state"
	@echo "  make re          Fully rebuild the VM and workloads"

.PHONY: help up down reload provision status validate ssh-server nodes pods clean fclean re
