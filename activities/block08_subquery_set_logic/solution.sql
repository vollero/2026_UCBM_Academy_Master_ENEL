-- Relational Databases & SQL - soluzione SQL blocco 8
-- Prerequisito: caricare prima ../../sql/01_schema_seed_postgres.sql
-- Target: PostgreSQL 13+

SET search_path TO training;

SELECT c.customer_id, c.full_name
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM order_revenue r
    WHERE r.customer_id = c.customer_id
      AND r.status NOT IN ('cancelled', 'refunded')
      AND r.gross_revenue > (
          SELECT avg(gross_revenue)
          FROM order_revenue
          WHERE status NOT IN ('cancelled', 'refunded')
      )
)
ORDER BY c.full_name;


SELECT p.product_id, p.sku, p.product_name
FROM products p
WHERE NOT EXISTS (
    SELECT 1
    FROM order_items oi
    WHERE oi.product_id = p.product_id
)
ORDER BY p.sku;

SELECT customer_id
FROM customers
EXCEPT
SELECT DISTINCT customer_id
FROM support_tickets
ORDER BY customer_id;
