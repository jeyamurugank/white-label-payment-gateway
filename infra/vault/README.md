
Vault integration notes

1) Example: write provider secrets into Vault (KV v2 at secret/data/payment_gateway/providers/<provider>)
   export VAULT_ADDR=https://vault.example.com
   export VAULT_TOKEN=<root-or-policy-token>

   # Razorpay
   vault kv put secret/payment_gateway/providers/razorpay key_id=rzp_test_123 key_secret=rzp_test_secret

   # Cashfree
   vault kv put secret/payment_gateway/providers/cashfree app_id=CF123456 secret_key=cf_secret

   # PayU
   vault kv put secret/payment_gateway/providers/payu key=payu_key salt=payu_salt

2) Policy file example: infra/vault/policies/payment-gateway-policy.hcl
   Apply it and create a token or bind via Kubernetes auth.

3) Kubernetes sidecar / agent approach (recommended):
   - Install Vault Agent Injector and annotate your Deployment with the required annotations to inject secrets as environment variables or files.
   - Or use the Vault CSI driver to mount secrets at runtime.

4) In the app, set VAULT_ADDR and VAULT_TOKEN (or use Vault Agent injected token file). The included vault.client will call /v1/<path> and is KV v2 aware.
