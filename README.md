# Vault K8s Project

HashiCorp Vault deployment on Kubernetes with GitHub Actions CI/CD.

## Features

- **HashiCorp Vault** - Secrets management on Kubernetes
- **Docker Desktop K8s** - Local development ready
- **GitHub Actions** - Automated CI/CD pipelines
- **Dev Mode** - Quick start with in-memory storage

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) with Kubernetes enabled
- [kubectl](https://kubernetes.io/docs/tasks/tools/) CLI
- [Vault CLI](https://developer.hashicorp.com/vault/downloads) (optional, for local testing)

## Quick Start

### 1. Enable Docker Desktop Kubernetes

Open Docker Desktop → Settings → Kubernetes → Enable Kubernetes

### 2. Deploy Vault

```bash
# Switch to docker-desktop context
kubectl config use-context docker-desktop

# Deploy Vault
make deploy

# Or manually:
kubectl apply -f k8s/
```

### 3. Access Vault

```bash
# Port forward to access Vault UI
make port-forward

# Open browser: http://localhost:8200
# Token: root (dev mode only)
```

### 4. Test with CLI

```bash
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='root'

# Enable KV secrets engine
vault secrets enable -path=secret kv-v2

# Write a secret
vault kv put secret/myapp password=supersecret

# Read it back
vault kv get secret/myapp
```

## Project Structure

```
├── .github/workflows/    # GitHub Actions CI/CD
│   ├── ci.yaml          # Lint & validate on PR
│   └── deploy.yaml      # Deploy to K8s
├── k8s/                 # Kubernetes manifests
│   ├── namespace.yaml   # Vault namespace
│   ├── vault-config.yaml# ConfigMap
│   ├── vault-dev.yaml   # Dev deployment
│   └── vault-service.yaml# Service
├── scripts/             # Helper scripts
│   ├── init-vault.sh    # Initialize Vault
│   └── unseal-vault.sh  # Unseal Vault
├── Makefile             # Common commands
└── README.md
```

## Make Commands

| Command | Description |
|---------|-------------|
| `make deploy` | Deploy Vault to K8s |
| `make delete` | Remove Vault deployment |
| `make port-forward` | Access Vault at localhost:8200 |
| `make status` | Check deployment status |
| `make logs` | View Vault logs |
| `make clean` | Full cleanup |

## GitHub Actions

### CI Workflow (ci.yaml)
Runs on pull requests:
- YAML linting with yamllint
- Kubernetes manifest validation
- Schema validation with kubeval

### Deploy Workflow (deploy.yaml)
Manual trigger or push to main:
- Applies K8s manifests to cluster
- Requires `KUBECONFIG_BASE64` secret

### Setting Up GitHub Secrets

1. Encode your kubeconfig:
   ```bash
   cat ~/.kube/config | base64 -w 0
   ```

2. Go to: Repository → Settings → Secrets → Actions

3. Add secret: `KUBECONFIG_BASE64` with the encoded value

## Configuration

### Dev Mode (Default)
- In-memory storage (data lost on restart)
- Auto-unsealed
- Root token: `root`
- Perfect for local development

### Production Mode
For production, modify `vault-config.yaml`:
- Enable TLS
- Use persistent storage (Consul/Raft)
- Configure proper authentication

## Troubleshooting

### Pod not starting
```bash
kubectl describe pod -n vault -l app=vault
kubectl logs -n vault -l app=vault
```

### Connection refused
Ensure port-forward is running:
```bash
make port-forward
```

### Context not found
```bash
kubectl config get-contexts
kubectl config use-context docker-desktop
```

## License

MIT
