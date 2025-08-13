
-- create_indexes_concurrently.sql
-- Run this outside of transactions during a maintenance window.
-- It finds partitions under payment_gateway schema and runs CREATE INDEX CONCURRENTLY per partition.
DO $$
DECLARE r RECORD; idx TEXT;
BEGIN
  FOR r IN SELECT relname FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='payment_gateway' AND relname LIKE 'transactions_%' AND c.relkind='r' LOOP
    idx := format('CREATE INDEX CONCURRENTLY IF NOT EXISTS %I ON payment_gateway.%I (created_at);', r.relname || '_created_at_idx', r.relname);
    RAISE NOTICE '%', idx; EXECUTE idx;
    idx := format('CREATE INDEX CONCURRENTLY IF NOT EXISTS %I ON payment_gateway.%I (provider_tx_id);', r.relname || '_provider_txid_idx', r.relname);
    RAISE NOTICE '%', idx; EXECUTE idx;
    idx := format('CREATE INDEX CONCURRENTLY IF NOT EXISTS %I ON payment_gateway.%I (merchant_id, status, created_at);', r.relname || '_merchant_status_idx', r.relname);
    RAISE NOTICE '%', idx; EXECUTE idx;
  END LOOP;
END $$;
