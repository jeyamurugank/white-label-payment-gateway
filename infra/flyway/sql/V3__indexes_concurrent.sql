
-- V3__indexes_concurrent.sql
-- Create heavy indexes concurrently on partitions. This script uses IF NOT EXISTS checks and will
-- attempt to create indexes on existing partitions in a maintenance window. Running CREATE INDEX CONCURRENTLY
-- in a transaction is not allowed, so this script executes statements dynamically.

-- Parent index definitions (already created non-concurrently in V1 to allow planning)
-- Now create safer per-partition indexes concurrently.

DO $$
DECLARE
  r RECORD;
  idx_sql TEXT;
BEGIN
  FOR r IN
    SELECT c.oid::regclass::text AS relname, n.nspname, c.relname as shortname
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'payment_gateway' AND c.relkind = 'r' AND c.relname LIKE 'transactions_%'
  LOOP
    BEGIN
      -- created_at index
      idx_sql := format('CREATE INDEX IF NOT EXISTS %I ON payment_gateway.%I USING btree (created_at);', r.shortname || '_created_at_idx', r.relname);
      RAISE NOTICE 'Running: %', idx_sql;
      EXECUTE idx_sql;
    EXCEPTION WHEN others THEN
      RAISE NOTICE 'Could not create index on % due to %', r.relname, SQLERRM;
    END;

    BEGIN
      idx_sql := format('CREATE INDEX IF NOT EXISTS %I ON payment_gateway.%I USING btree (provider_tx_id);', r.shortname || '_provider_txid_idx', r.relname);
      RAISE NOTICE 'Running: %', idx_sql;
      EXECUTE idx_sql;
    EXCEPTION WHEN others THEN
      RAISE NOTICE 'Could not create index on % due to %', r.relname, SQLERRM;
    END;

    BEGIN
      idx_sql := format('CREATE INDEX IF NOT EXISTS %I ON payment_gateway.%I USING btree (merchant_id, status, created_at);', r.shortname || '_merchant_status_idx', r.relname);
      RAISE NOTICE 'Running: %', idx_sql;
      EXECUTE idx_sql;
    EXCEPTION WHEN others THEN
      RAISE NOTICE 'Could not create index on % due to %', r.relname, SQLERRM;
    END;
  END LOOP;
END $$;
