
-- V4__domain_models.sql
-- Additional constraints, views, and helper functions for domain logic

SET search_path = payment_gateway, public;

-- Add trigger to keep updated_at in sync
CREATE OR REPLACE FUNCTION payment_gateway.trigger_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach trigger to tables where required
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'set_updated_at_transactions') THEN
    CREATE TRIGGER set_updated_at_transactions BEFORE UPDATE ON payment_gateway.transactions FOR EACH ROW EXECUTE FUNCTION payment_gateway.trigger_set_updated_at();
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'set_updated_at_merchants') THEN
    CREATE TRIGGER set_updated_at_merchants BEFORE UPDATE ON payment_gateway.merchants FOR EACH ROW EXECUTE FUNCTION payment_gateway.trigger_set_updated_at();
  END IF;
END $$;

-- Convenience view for reconciliation
CREATE OR REPLACE VIEW payment_gateway.v_recent_transactions AS
SELECT id, merchant_id, provider_tx_id, amount, currency, status, created_at, updated_at
FROM payment_gateway.transactions
WHERE created_at >= now() - INTERVAL '90 days';
