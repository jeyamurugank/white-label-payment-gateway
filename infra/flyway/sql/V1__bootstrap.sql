
-- V1__bootstrap.sql
-- Create schema, extensions, parent tables and base settings
CREATE SCHEMA IF NOT EXISTS payment_gateway;
CREATE EXTENSION IF NOT EXISTS pgcrypto;
SET search_path = payment_gateway, public;

-- Core domain tables
CREATE TABLE IF NOT EXISTS merchants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  email TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS providers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT UNIQUE NOT NULL,
  type TEXT NOT NULL,
  config JSONB,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Parent transactions table partitioned by month
CREATE TABLE IF NOT EXISTS transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  merchant_id UUID REFERENCES merchants(id),
  provider_id UUID REFERENCES providers(id),
  provider_tx_id TEXT,
  amount NUMERIC(18,2),
  currency CHAR(3) DEFAULT 'INR',
  status TEXT,
  metadata JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
) PARTITION BY RANGE (created_at);

-- Domain tables (non-partitioned)
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  merchant_id UUID NOT NULL REFERENCES merchants(id),
  email TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  role TEXT DEFAULT 'user',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  merchant_id UUID NOT NULL REFERENCES merchants(id),
  sku TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  price NUMERIC(18,2) NOT NULL,
  currency CHAR(3) DEFAULT 'INR',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  merchant_id UUID NOT NULL REFERENCES merchants(id),
  user_id UUID NOT NULL REFERENCES users(id),
  status TEXT DEFAULT 'created',
  amount NUMERIC(18,2) NOT NULL,
  currency CHAR(3) DEFAULT 'INR',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES orders(id),
  product_id UUID NOT NULL REFERENCES products(id),
  qty INT NOT NULL,
  price NUMERIC(18,2) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ApiKey table for merchant API keys
CREATE TABLE IF NOT EXISTS api_keys (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  merchant_id UUID NOT NULL REFERENCES merchants(id),
  key TEXT UNIQUE NOT NULL,
  revoked BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Basic parent indexes (will be created concurrently on partitions later)
CREATE INDEX IF NOT EXISTS idx_transactions_provider_tx_id_parent ON payment_gateway.transactions (provider_tx_id);
CREATE INDEX IF NOT EXISTS idx_transactions_merchant_status_parent ON payment_gateway.transactions (merchant_id, status, created_at);
