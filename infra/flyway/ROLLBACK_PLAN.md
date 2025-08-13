
Flyway Rollback Plan & Migration Strategy
========================================

Principles
- Flyway migrations are forward-only by default. Rollbacks must be implemented as new migrations that reverse changes where possible.
- Always run migrations first in staging and run smoke tests before promoting to production.
- For destructive operations (DROP, ALTER COLUMN, massive INDEX creation), schedule a maintenance window and create a reversible plan.

Suggested process
1. Create a Vx__describe_change.sql migration that performs the forward change.
2. Add a FX__undo_describe_change.sql (prefix F for "fix" or R for "repair") that, when needed, undoes the change. Keep these in a separate `undo` folder and do not run automatically—execute after manual review.
3. Use backups: take logical (pg_dump) and physical (basebackup) before running risky migrations.
4. Index creation: prefer CREATE INDEX CONCURRENTLY executed outside a transaction during maintenance windows.
5. Rolling changes: for schema changes, prefer additive migrations (add columns, new tables, backfill), then switch application to read/write both columns, then remove old columns in a later migration.

Example undo pattern
- Forward migration: V10__add_new_col.sql —> adds column and backfills data
- Undo migration: U10__remove_new_col.sql —> drops column (run only after verification)

Operational checklist (pre-deploy)
- Validate backups exist and are restorable (test restore to staging)
- Ensure runbook and on-call contact list are available
- Notify stakeholders and open maintenance ticket with start/end times
- Run migration in a runway node / single primary before scale-up (if read replicas exist, follow steps to drain and sync)

Automated gating (CI/CD)
- CI runs Flyway migrations against a disposable environment (ephemeral DB)
- PRs that modify sql migrations require review and tagging with "migration-reviewed"
- Production workflow must target a protected environment in GitHub Actions with required approvers
