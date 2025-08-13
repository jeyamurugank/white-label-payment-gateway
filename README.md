Payment Gateway Enterprise - Recreated Repo

Contents:
- NestJS API with multi-provider adapters (Razorpay, Cashfree, PayU)
- Enterprise features: merchant onboarding, API keys, rate-limiter, audit logger, reconciliation script, partition manager, metrics endpoint
- Prisma schema and helper to run `prisma db pull` and `prisma generate`
- Flyway migrations (infra/flyway/sql) placeholders
- Dockerfile and docker-compose for local dev (Postgres + Flyway + API)

Quick start (dev):
1. Copy .env.example -> .env and set DATABASE_URL
2. docker compose up --build (runs Postgres and Flyway migrations)
3. Run `./scripts/prisma_pull_and_generate.sh` to pull schema and generate Prisma client (requires DB)


Expanded Flyway production SQL and Vault integration added. See infra/vault/* for policy and usage. Use KV v2 paths like `secret/payment_gateway/providers/razorpay`.


Added Redis global rate limiter, cloud Helm values (EKS/GKE/AKS), GitHub environment setup script, and Helm install guide under infra/helm.
