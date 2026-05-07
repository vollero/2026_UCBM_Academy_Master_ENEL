-- Relational Databases & SQL - Blocco 11
-- Gentle introduction: Performance, EXPLAIN e indici
-- Prerequisito: caricare sql/01_schema_seed_postgres.sql

SET search_path TO training;

-- 1. Piano di una query filtrata
EXPLAIN (ANALYZE, BUFFERS)
SELECT order_id, order_date, status
FROM orders
WHERE customer_id = 1
ORDER BY order_date;

-- 2. Indice candidato
BEGIN;

CREATE INDEX idx_orders_customer_date
ON orders (customer_id, order_date);

EXPLAIN (ANALYZE, BUFFERS)
SELECT order_id, order_date, status
FROM orders
WHERE customer_id = 1
ORDER BY order_date;

ROLLBACK;

-- 3. Indice per join frequente
BEGIN;

CREATE INDEX idx_order_items_product
ON order_items (product_id);

EXPLAIN (ANALYZE, BUFFERS)
SELECT p.product_name, sum(oi.quantity) AS units
FROM order_items AS oi
JOIN products AS p ON p.product_id = oi.product_id
GROUP BY p.product_name;

ROLLBACK;
