-- Relational Databases & SQL - soluzione SQL blocco 6
-- Prerequisito: caricare prima ../../sql/01_schema_seed_postgres.sql
-- Target: PostgreSQL 13+

SET search_path TO training;

SELECT date_trunc('month', order_date)::date AS month,
       channel,
       round(sum(gross_revenue), 2) AS revenue
FROM order_revenue
WHERE status NOT IN ('cancelled', 'refunded')
GROUP BY month, channel
ORDER BY month, channel;

SELECT c.country,
       count(DISTINCT r.order_id) AS orders,
       round(sum(r.gross_revenue), 2) AS revenue
FROM order_revenue r
JOIN customers c ON c.customer_id = r.customer_id
WHERE r.status NOT IN ('cancelled', 'refunded')
GROUP BY c.country
ORDER BY revenue DESC;


SELECT c.segment,
       count(*) AS valid_orders,
       round(sum(r.gross_revenue), 2) AS revenue,
       round(avg(r.gross_revenue), 2) AS avg_order_value
FROM order_revenue r
JOIN customers c ON c.customer_id = r.customer_id
WHERE r.status NOT IN ('cancelled', 'refunded')
GROUP BY c.segment
HAVING count(*) >= 2
ORDER BY revenue DESC;

SELECT channel,
       count(*) FILTER (WHERE status = 'completed') AS completed_orders,
       count(*) FILTER (WHERE status = 'shipped') AS shipped_orders,
       count(*) FILTER (WHERE status = 'pending') AS pending_orders
FROM orders
GROUP BY channel
ORDER BY channel;
