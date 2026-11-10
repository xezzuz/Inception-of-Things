.DEFAULT_GOAL := help

SERVER_NODE := nazouzBonus
SERVER_IP := 192.168.56.120

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

gitlab-password:
	vagrant ssh $(SERVER_NODE) -c 'sudo cat /etc/gitlab/initial_root_password'

argocd-password:
	vagrant ssh $(SERVER_NODE) -c 'argocd admin initial-password -n argocd'

argocd-ui:
	@echo "Log in with username: admin"
	@printf "Password: "
	@vagrant ssh $(SERVER_NODE) -c 'argocd admin initial-password -n argocd'
	@echo "Argo CD UI: https://$(SERVER_IP):8080 (press Ctrl-C to stop)"
	vagrant ssh $(SERVER_NODE) -c 'kubectl -n argocd port-forward service/argocd-server 8080:443 --address 0.0.0.0'

nodes:
	vagrant ssh $(SERVER_NODE) -c 'kubectl get nodes -o wide'

pods:
	vagrant ssh $(SERVER_NODE) -c 'kubectl get pods -A'

verify:
	vagrant ssh $(SERVER_NODE) -c 'kubectl wait --for=jsonpath="{.status.sync.status}"=Synced application/playground-dev -n argocd --timeout=5m && kubectl wait --for=jsonpath="{.status.health.status}"=Healthy application/playground-dev -n argocd --timeout=5m && kubectl rollout status deployment/playground -n dev --timeout=5m && curl --fail --silent --show-error --max-time 15 http://127.0.0.1:8889/'

clean:
	vagrant destroy -f

fclean: clean
	rm -rf .vagrant

re:
	$(MAKE) fclean
	$(MAKE) up

help:
	@echo "Available targets:"
	@echo "  make up          Create the bonus VM and run its initial provisioning"
	@echo "  make down        Halt the VM while keeping its disk"
	@echo "  make reload      Reload the VM to apply Vagrantfile changes"
	@echo "  make provision   Rerun GitLab, K3d, and Argo CD provisioning"
	@echo "  make status      Show the Vagrant machine status"
	@echo "  make validate    Validate the Vagrantfile and Bash scripts"
	@echo "  make ssh-server  Open an SSH session on the bonus server"
	@echo "  make gitlab-password  Print GitLab's initial root password (available for 24 hours)"
	@echo "  make argocd-password  Print Argo CD's initial admin password"
	@echo "  make argocd-ui  Expose the Argo CD UI at https://$(SERVER_IP):8080"
	@echo "  make nodes       Show Kubernetes nodes"
	@echo "  make pods        Show pods in every namespace"
	@echo "  make verify      Confirm Argo CD sync and the playground endpoint"
	@echo "  make clean       Destroy the VM but keep local Vagrant state"
	@echo "  make fclean      Destroy the VM and remove local Vagrant state"
	@echo "  make re          Fully rebuild the bonus VM and workloads"

.PHONY: help up down reload provision status validate ssh-server gitlab-password argocd-password argocd-ui nodes pods verify clean fclean re
