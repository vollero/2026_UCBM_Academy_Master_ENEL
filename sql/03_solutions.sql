-- Relational Databases & SQL - soluzioni SQL generate
-- Le soluzioni SQL partono dal blocco 4: i blocchi 1-3 sono modellazione.

-- ============================================================
-- Blocco 4 - Prime query SQL
-- ============================================================

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

-- ============================================================
-- Blocco 5 - JOIN e cardinalita
-- ============================================================

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

-- ============================================================
-- Blocco 6 - Aggregazioni e KPI
-- ============================================================

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

-- ============================================================
-- Blocco 7 - DDL, DML e transazioni
-- ============================================================

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

-- ============================================================
-- Blocco 8 - Subquery e logica insiemistica
-- ============================================================

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

-- ============================================================
-- Blocchi 9-12 - Architettura ticketing, dashboard e performance
-- ============================================================

-- I blocchi 9-12 usano uno schema dedicato al caso architetturale ticketing.
-- Eseguire in sequenza:
--   sql/ticket_architecture_schema.sql
--   sql/ticket_architecture_dashboard_queries.sql
-- e poi le solution.sql dei blocchi 9-12.

SELECT 'Blocchi 9-12: usare gli script ticket_architecture_* dedicati' AS note;
