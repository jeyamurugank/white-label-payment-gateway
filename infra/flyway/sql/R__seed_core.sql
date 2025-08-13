
-- R__seed_core.sql
INSERT INTO payment_gateway.merchants (name, slug, email)
VALUES ('Acme Retail', 'acme-retail', 'ops@acme.example')
ON CONFLICT (slug) DO NOTHING;

INSERT INTO payment_gateway.providers (name, type, config)
VALUES ('razorpay', 'payments', '{}'::jsonb),
       ('cashfree', 'payments', '{}'::jsonb),
       ('payu', 'payments', '{}'::jsonb)
ON CONFLICT (name) DO NOTHING;
