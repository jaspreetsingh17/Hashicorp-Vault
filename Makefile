# Vault K8s Project

# Variables
NAMESPACE := vault
VAULT_POD := $(shell kubectl get pod -n $(NAMESPACE) -l app=vault -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

.PHONY: deploy delete port-forward status logs init unseal clean help

## Deploy Vault to Kubernetes
deploy:
	@echo "Deploying Vault to Kubernetes..."
	kubectl apply -f k8s/namespace.yaml
	kubectl apply -f k8s/
	@echo "Waiting for Vault to be ready..."
	kubectl wait --for=condition=ready pod -l app=vault -n $(NAMESPACE) --timeout=120s
	@echo "Vault deployed successfully!"
	@echo "Run 'make port-forward' to access Vault UI"

## Delete Vault deployment
delete:
	@echo "Deleting Vault deployment..."
	kubectl delete -f k8s/ --ignore-not-found
	@echo "Vault deleted"

## Port forward to access Vault locally
port-forward:
	@echo "Port forwarding Vault to localhost:8200..."
	@echo "Access Vault UI at: http://localhost:8200"
	@echo "Token (dev mode): root"
	@echo "Press Ctrl+C to stop"
	kubectl port-forward svc/vault -n $(NAMESPACE) 8200:8200

## Check deployment status
status:
	@echo "Vault Status:"
	@kubectl get all -n $(NAMESPACE)

## View Vault logs
logs:
	@kubectl logs -n $(NAMESPACE) -l app=vault -f

## Initialize Vault (production mode only)
init:
	@echo "Initializing Vault..."
	./scripts/init-vault.sh

## Unseal Vault (production mode only)
unseal:
	@echo "Unsealing Vault..."
	./scripts/unseal-vault.sh

## Full cleanup including namespace
clean:
	@echo "Cleaning up Vault deployment..."
	kubectl delete namespace $(NAMESPACE) --ignore-not-found
	@echo "Cleanup complete"

## Show help
help:
	@echo "Available targets:"
	@echo "  deploy       - Deploy Vault to Kubernetes"
	@echo "  delete       - Delete Vault deployment"
	@echo "  port-forward - Access Vault at localhost:8200"
	@echo "  status       - Check deployment status"
	@echo "  logs         - View Vault logs"
	@echo "  init         - Initialize Vault (production)"
	@echo "  unseal       - Unseal Vault (production)"
	@echo "  clean        - Full cleanup including namespace"
	@echo "  help         - Show this help"
