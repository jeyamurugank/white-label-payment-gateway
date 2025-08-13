
-- V2__create_partitions.sql
-- Create monthly partitions for transactions table for a window of months around now.
-- This script is safe to re-run; it will only create missing partitions.

DO $$
DECLARE
  start_month DATE := date_trunc('month', now())::date - INTERVAL '1 month'; -- start from previous month
  months INTEGER := COALESCE(current_setting('payment_gateway.partition_months', true)::int, 36);
  i INTEGER := 0;
  part_name TEXT;
  from_ts TIMESTAMPTZ;
  to_ts TIMESTAMPTZ;
BEGIN
  WHILE i < months LOOP
    from_ts := (start_month + (i || ' month')::interval)::timestamptz;
    to_ts := (start_month + ((i+1) || ' month')::interval)::timestamptz;
    part_name := format('transactions_%s', to_char(from_ts, 'YYYY_MM'));
    -- create partition if not exists
    EXECUTE format('CREATE TABLE IF NOT EXISTS payment_gateway.%I PARTITION OF payment_gateway.transactions FOR VALUES FROM (%L) TO (%L);', part_name, from_ts, to_ts);
    i := i + 1;
  END LOOP;
END $$;
