-- Relational Databases & SQL - soluzione SQL blocco 7
-- Prerequisito: caricare prima ../../sql/01_schema_seed_postgres.sql
-- Target: PostgreSQL 13+

SET search_path TO training;

BEGIN;

SELECT product_id, sku, unit_price
FROM products
WHERE category = 'accessories' AND active
ORDER BY product_id;

CREATE TABLE IF NOT EXISTS product_price_audit (
    audit_id bigserial PRIMARY KEY,
    product_id integer NOT NULL REFERENCES products(product_id),
    old_price numeric(10,2) NOT NULL,
    new_price numeric(10,2) NOT NULL,
    reason text NOT NULL,
    changed_at timestamp NOT NULL DEFAULT now()
);


WITH candidates AS (
    SELECT product_id, unit_price AS old_price,
           round(unit_price * 1.05, 2) AS new_price
    FROM products
    WHERE category = 'accessories' AND active
), changed AS (
    UPDATE products p
    SET unit_price = c.new_price
    FROM candidates c
    WHERE c.product_id = p.product_id
    RETURNING p.product_id, c.old_price, p.unit_price AS new_price
)
INSERT INTO product_price_audit(product_id, old_price, new_price, reason)
SELECT product_id, old_price, new_price, 'annual price review'
FROM changed;

SELECT * FROM product_price_audit ORDER BY audit_id DESC;

ROLLBACK;
