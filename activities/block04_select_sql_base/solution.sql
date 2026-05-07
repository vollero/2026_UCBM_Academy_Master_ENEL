-- Relational Databases & SQL - soluzione SQL blocco 4
-- Prerequisito: caricare prima ../../sql/01_schema_seed_postgres.sql
-- Target: PostgreSQL 13+

SET search_path TO training;

SELECT product_id, sku, product_name, unit_price
FROM products
WHERE active
ORDER BY unit_price DESC, product_id;

SELECT customer_id, full_name, country, signup_date
FROM customers
WHERE signup_date >= DATE '2025-02-01'
ORDER BY signup_date, customer_id;


SELECT order_id, customer_id, order_date, status, channel
FROM orders
WHERE status IN ('pending', 'cancelled', 'refunded')
ORDER BY order_date, order_id;

SELECT order_id, product_id,
       round(quantity * unit_price * (1 - discount_pct / 100.0), 2) AS net_amount
FROM order_items
ORDER BY order_id, product_id;

SELECT shipment_id, order_id, shipped_at, delivered_at
FROM shipments
WHERE delivered_at IS NULL
ORDER BY shipped_at, shipment_id;
