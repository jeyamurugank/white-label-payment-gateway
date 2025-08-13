
-- safe_create_index_function.sql
-- Helper to attempt CREATE INDEX CONCURRENTLY with wait/retry via DO loops in external scripts.
CREATE OR REPLACE FUNCTION payment_gateway.safe_create_index_concurrently(p_table TEXT, p_index_sql TEXT)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
  EXECUTE p_index_sql;
EXCEPTION WHEN others THEN
  RAISE NOTICE 'Index creation failed: %', SQLERRM;
END;
$$;
