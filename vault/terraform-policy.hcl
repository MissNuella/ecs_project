# Least-privilege policy for the token Terraform uses.
# It can read the app's database secret and nothing else.
path "secret/data/ecs-notes/*" {
  capabilities = ["read"]
}

path "secret/metadata/ecs-notes/*" {
  capabilities = ["read"]
}

# The Terraform Vault provider creates a short-lived child token.
path "auth/token/create" {
  capabilities = ["update"]
}
