#!/bin/bash
# Unseal Vault using keys from init-vault.sh
# For production mode only - dev mode auto-unseals

set -e

NAMESPACE="${NAMESPACE:-vault}"
KEYS_FILE="${KEYS_FILE:-vault-unseal-keys.txt}"

echo "Unsealing Vault..."

# Check if keys file exists
if [ ! -f "$KEYS_FILE" ]; then
    echo "ERROR: Keys file not found: $KEYS_FILE"
    echo "Run './scripts/init-vault.sh' first to generate unseal keys."
    exit 1
fi

# Read unseal keys (need 3 of 5 by default)
KEYS=($(cat "$KEYS_FILE"))
THRESHOLD=3

for i in $(seq 0 $((THRESHOLD - 1))); do
    echo "Applying unseal key $((i + 1))/$THRESHOLD..."
    kubectl exec -n "$NAMESPACE" vault-0 -- vault operator unseal "${KEYS[$i]}"
done

# Check seal status
STATUS=$(kubectl exec -n "$NAMESPACE" vault-0 -- vault status -format=json | jq -r '.sealed')

if [ "$STATUS" = "false" ]; then
    echo ""
    echo "Vault is now unsealed!"
    echo ""
    echo "To login, use the root token from: vault-root-token.txt"
else
    echo ""
    echo "WARNING: Vault is still sealed. You may need more unseal keys."
fi
