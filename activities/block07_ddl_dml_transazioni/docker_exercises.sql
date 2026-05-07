-- Relational Databases & SQL - Blocco 7
-- Esercitazioni Docker
-- Prerequisito: caricare sql/01_schema_seed_postgres.sql

SET search_path TO training;

-- Esercizio 1: Audit prezzi
-- Richiesta: Creare una tabella di audit prezzi con riferimento al prodotto.
CREATE TABLE IF NOT EXISTS product_price_audit (
  audit_id bigserial PRIMARY KEY,
  product_id integer NOT NULL REFERENCES products(product_id),
  old_price numeric(10, 2) NOT NULL,
  new_price numeric(10, 2) NOT NULL,
  changed_at timestamp NOT NULL DEFAULT now()
);

-- Esercizio 2: Update controllato
-- Richiesta: Dentro una transazione, aumentare del 5% gli accessori attivi e mostrare le righe modificate.
BEGIN;

UPDATE products
SET unit_price = round(unit_price * 1.05, 2)
WHERE category = 'accessories'
  AND active = true
RETURNING product_id, sku, unit_price;

ROLLBACK;

-- Esercizio 3: Inserimento di test
-- Richiesta: Inserire un prodotto di test dentro una transazione e annullare la modifica.
BEGIN;

INSERT INTO products (product_id, sku, product_name, category, unit_price, active)
VALUES (1000, 'LAB-SVC', 'Laboratory Service', 'services', 250.00, true)
RETURNING product_id, sku, product_name;

ROLLBACK;
