
# Vault policy for Payment Gateway service - least privilege for secrets
path "secret/data/payment_gateway/*" {
  capabilities = ["read", "list"]
}

path "kv/data/providers/*" {
  capabilities = ["read", "list"]
}

# Allow token lookup (optional for operators)
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
