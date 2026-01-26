#!/bin/bash
# Initialize Vault (for production mode, not needed for dev mode)
# This script generates unseal keys and root token

set -e

NAMESPACE="${NAMESPACE:-vault}"

echo "Initializing Vault..."

# Check if Vault is already initialized
INIT_STATUS=$(kubectl exec -n "$NAMESPACE" vault-0 -- vault status -format=json 2>/dev/null | jq -r '.initialized' || echo "false")

if [ "$INIT_STATUS" = "true" ]; then
    echo "WARNING: Vault is already initialized!"
    exit 0
fi

# Initialize Vault
echo "Initializing Vault with 5 key shares and 3 key threshold..."
INIT_OUTPUT=$(kubectl exec -n "$NAMESPACE" vault-0 -- vault operator init \
    -key-shares=5 \
    -key-threshold=3 \
    -format=json)

# Extract and save keys
echo "$INIT_OUTPUT" | jq -r '.unseal_keys_b64[]' > vault-unseal-keys.txt
echo "$INIT_OUTPUT" | jq -r '.root_token' > vault-root-token.txt

echo ""
echo "Vault initialized successfully!"
echo ""
echo "IMPORTANT: Save these files securely and delete them after storing:"
echo "   - vault-unseal-keys.txt (5 unseal keys)"
echo "   - vault-root-token.txt (root token)"
echo ""
echo "To unseal Vault, run: ./scripts/unseal-vault.sh"
