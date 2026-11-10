.DEFAULT_GOAL := help

CLUSTER_NAME := iot-p3
KUBECTL := kubectl --context k3d-$(CLUSTER_NAME)

install:
	./scripts/install-tools.sh

# Resume an existing stopped cluster before the setup script's readiness checks.
up:
	@if k3d cluster get "$(CLUSTER_NAME)" >/dev/null 2>&1; then k3d cluster start "$(CLUSTER_NAME)"; fi
	./scripts/setup-cluster.sh
	./scripts/setup-argocd.sh

start:
	k3d cluster start "$(CLUSTER_NAME)"

down:
	k3d cluster stop "$(CLUSTER_NAME)"

stop: down

clean:
	k3d cluster delete "$(CLUSTER_NAME)"

re:
	$(MAKE) clean
	$(MAKE) up

status:
	k3d cluster list
	$(KUBECTL) get application playground-dev -n argocd

nodes:
	$(KUBECTL) get nodes -o wide

pods:
	$(KUBECTL) get pods -A

argocd-password:
	argocd admin initial-password --kube-context k3d-$(CLUSTER_NAME) -n argocd

argocd-ui:
	@echo "Log in with username: admin"
	@printf "Password: "
	@argocd admin initial-password --kube-context k3d-$(CLUSTER_NAME) -n argocd
	@echo "Argo CD UI: https://127.0.0.1:8080 (press Ctrl-C to stop)"
	$(KUBECTL) -n argocd port-forward service/argocd-server 8080:443 --address 0.0.0.0

verify:
	$(KUBECTL) wait --for=jsonpath='{.status.sync.status}'=Synced application/playground-dev -n argocd --timeout=5m
	$(KUBECTL) wait --for=jsonpath='{.status.health.status}'=Healthy application/playground-dev -n argocd --timeout=5m
	$(KUBECTL) rollout status deployment/playground -n dev --timeout=5m
	$(KUBECTL) get deployment,pods,service,ingress -n dev
	curl --fail --silent --show-error --max-time 15 http://127.0.0.1:8888/
	@echo

validate:
	@set -e; for script in scripts/*.sh; do bash -n "$$script"; done


help:
	@echo "make install   Install required macOS tools"
	@echo "make up        Create/resume the cluster and set up Argo CD + GitOps"
	@echo "make start     Resume the existing cluster"
	@echo "make down      Stop the cluster, preserving its data"
	@echo "make clean     DELETE the cluster and all resources/data inside it"
	@echo "make re        Delete the cluster and rebuild it"
	@echo "make status    Show cluster and Argo CD application status"
	@echo "make nodes     Show Kubernetes nodes"
	@echo "make pods      Show Pods across namespaces"
	@echo "make argocd-password  Print Argo CD's initial admin password"
	@echo "make argocd-ui  Expose the Argo CD UI at https://127.0.0.1:8080"
	@echo "make verify    Wait for GitOps sync/health and test the HTTP endpoint"
	@echo "make validate  Check Bash syntax"

.PHONY: help install up start down stop clean destroy re status nodes pods argocd-password argocd-ui verify validate
