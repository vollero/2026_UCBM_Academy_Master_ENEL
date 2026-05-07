-- Relational Databases & SQL - Blocco 7
-- Gentle introduction: DDL, DML e transazioni
-- Prerequisito: caricare sql/01_schema_seed_postgres.sql

SET search_path TO training;

-- 1. Creare una tabella di audit
CREATE TABLE IF NOT EXISTS product_price_audit (
  audit_id bigserial PRIMARY KEY,
  product_id integer NOT NULL REFERENCES products(product_id),
  old_price numeric(10, 2) NOT NULL,
  new_price numeric(10, 2) NOT NULL,
  changed_at timestamp NOT NULL DEFAULT now()
);

-- 2. Aggiornamento controllato con rollback
BEGIN;

SELECT product_id, sku, unit_price
FROM products
WHERE category = 'accessories' AND active = true
ORDER BY product_id;

UPDATE products
SET unit_price = round(unit_price * 1.05, 2)
WHERE category = 'accessories' AND active = true
RETURNING product_id, sku, unit_price;

ROLLBACK;

-- 3. Inserimento controllato
BEGIN;

INSERT INTO products (product_id, sku, product_name, category, unit_price, active)
VALUES (1000, 'LAB-SVC', 'Laboratory Service', 'services', 250.00, true)
RETURNING product_id, sku, product_name;

ROLLBACK;
