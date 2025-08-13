
Maintenance Runbook - Index Creation & Migrations
-------------------------------------------------

Pre-checks:
- Verify backups: pg_dump and basebackup
- Notify stakeholders and set maintenance window
- Ensure primary node is healthy and replicas are streaming

Index creation steps (concurrent):
1. Take a logical backup of affected partitions (optional)
2. Run infra/db_maintenance/create_indexes_concurrently.sql via psql during quiet hours
   psql "$DATABASE_URL" -f infra/db_maintenance/create_indexes_concurrently.sql
3. Monitor pg_stat_activity for long-running queries and locks

Rollback commands (if index creation severely impacts cluster):
- Drop the newly created index (if created):
  DROP INDEX IF EXISTS payment_gateway.transactions_YYYY_MM_created_at_idx;
- Restore from backup if schema changes were destructive.

Migration rollback (example):
- If forward migration added a column `new_col`, undo migration U__remove_new_col.sql should be applied manually:
  psql "$DATABASE_URL" -f infra/flyway/undo/U__remove_new_col.sql
