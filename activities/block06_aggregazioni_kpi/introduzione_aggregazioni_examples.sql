-- Relational Databases & SQL - Blocco 6
-- Gentle introduction: Aggregazioni e KPI
-- Prerequisito: caricare sql/01_schema_seed_postgres.sql

SET search_path TO training;

-- 1. Ricavo per mese e canale
SELECT date_trunc('month', order_date)::date AS month,
       channel,
       round(sum(gross_revenue), 2) AS revenue
FROM order_revenue
WHERE status NOT IN ('cancelled', 'refunded')
GROUP BY month, channel
ORDER BY month, channel;

-- 2. AOV per segmento
SELECT c.segment,
       count(*) AS valid_orders,
       round(sum(r.gross_revenue), 2) AS revenue,
       round(avg(r.gross_revenue), 2) AS avg_order_value
FROM order_revenue AS r
JOIN customers AS c ON c.customer_id = r.customer_id
WHERE r.status NOT IN ('cancelled', 'refunded')
GROUP BY c.segment
HAVING count(*) >= 2
ORDER BY revenue DESC;

-- 3. Quantità e ricavo per categoria
SELECT p.category,
       sum(oi.quantity) AS units,
       round(sum(oi.quantity * oi.unit_price *
                 (1 - oi.discount_pct / 100.0)), 2) AS revenue
FROM order_items AS oi
JOIN products AS p ON p.product_id = oi.product_id
JOIN orders AS o ON o.order_id = oi.order_id
WHERE o.status NOT IN ('cancelled', 'refunded')
GROUP BY p.category
ORDER BY revenue DESC;
