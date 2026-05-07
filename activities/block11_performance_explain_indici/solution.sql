-- Relational Databases & SQL - soluzione SQL blocco 11
-- Prerequisito: caricare prima ../../sql/01_schema_seed_postgres.sql
-- Target: PostgreSQL 13+

SET search_path TO training;

EXPLAIN (ANALYZE, BUFFERS)
SELECT order_id, customer_id, order_date, status
FROM orders
WHERE status = 'completed'
  AND order_date >= DATE '2025-01-01'
  AND order_date <  DATE '2025-07-01'
ORDER BY order_date, order_id;


CREATE INDEX IF NOT EXISTS idx_orders_completed_date
ON orders(order_date, order_id)
WHERE status = 'completed';

EXPLAIN (ANALYZE, BUFFERS)
SELECT order_id, customer_id, order_date, status
FROM orders
WHERE status = 'completed'
  AND order_date >= DATE '2025-01-01'
  AND order_date <  DATE '2025-07-01'
ORDER BY order_date, order_id;

DROP INDEX IF EXISTS idx_orders_completed_date;
