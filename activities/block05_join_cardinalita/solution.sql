-- Relational Databases & SQL - soluzione SQL blocco 5
-- Prerequisito: caricare prima ../../sql/01_schema_seed_postgres.sql
-- Target: PostgreSQL 13+

SET search_path TO training;

SELECT o.order_id, o.order_date, c.full_name, c.country, o.status
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
ORDER BY o.order_date, o.order_id;

SELECT o.order_id, c.full_name, p.sku, p.product_name,
       oi.quantity,
       round(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0), 2) AS net_amount
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN customers c ON c.customer_id = o.customer_id
JOIN products p ON p.product_id = oi.product_id
ORDER BY o.order_id, p.sku;


SELECT o.order_id, c.full_name, o.order_date, o.status,
       s.shipment_id, s.shipped_at, s.delivered_at
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
LEFT JOIN shipments s ON s.order_id = o.order_id
WHERE s.shipment_id IS NULL
ORDER BY o.order_date, o.order_id;

SELECT o.order_id, count(oi.product_id) AS line_rows
FROM orders o
LEFT JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY o.order_id
ORDER BY line_rows DESC, o.order_id;
