#!/usr/bin/env bash
# Seeds Vault with the database password and creates a scoped token for Terraform.
#
# Start a local dev server in another terminal first:
#   vault server -dev -dev-root-token-id=root
# Then:
#   export VAULT_ADDR=http://127.0.0.1:8200
#   export VAULT_TOKEN=root
#   ./vault/setup.sh
set -euo pipefail

: "${VAULT_ADDR:?Set VAULT_ADDR, e.g. http://127.0.0.1:8200}"
: "${VAULT_TOKEN:?Set VAULT_TOKEN to an admin/root token}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Dev servers already mount KV v2 at secret/. Enable it if this is a real server.
if ! vault secrets list -format=json | grep -q '"secret/"'; then
  vault secrets enable -path=secret kv-v2
fi

# RDS passwords cannot contain / @ " or spaces, so use hex.
DB_PASSWORD="$(openssl rand -hex 20)"
vault kv put secret/ecs-notes/db password="$DB_PASSWORD" username="notes"

vault policy write terraform-ecs-notes "$SCRIPT_DIR/terraform-policy.hcl"
TF_TOKEN="$(vault token create -policy=terraform-ecs-notes -ttl=8h -field=token)"

echo
echo "Secret stored at secret/ecs-notes/db."
echo "Use this scoped token for Terraform:"
echo "  export VAULT_TOKEN=$TF_TOKEN"
