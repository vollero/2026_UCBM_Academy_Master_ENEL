-- Relational Databases & SQL - Blocco 8
-- Gentle introduction: Subquery e logica insiemistica
-- Prerequisito: caricare sql/01_schema_seed_postgres.sql

SET search_path TO training;

-- 1. Prodotti mai venduti
SELECT p.product_id, p.sku, p.product_name
FROM products AS p
WHERE NOT EXISTS (
  SELECT 1
  FROM order_items AS oi
  WHERE oi.product_id = p.product_id
)
ORDER BY p.product_id;

-- 2. Clienti con ordine sopra la media
SELECT c.customer_id, c.full_name
FROM customers AS c
WHERE EXISTS (
  SELECT 1
  FROM order_revenue AS r
  WHERE r.customer_id = c.customer_id
    AND r.status NOT IN ('cancelled', 'refunded')
    AND r.gross_revenue > (
      SELECT avg(gross_revenue)
      FROM order_revenue
      WHERE status NOT IN ('cancelled', 'refunded')
    )
)
ORDER BY c.full_name;

-- 3. Differenza tra insiemi con EXCEPT
SELECT customer_id
FROM customers
EXCEPT
SELECT customer_id
FROM orders
ORDER BY customer_id;

-- 4. Subquery scalare: prodotti sopra il prezzo medio
SELECT product_id, sku, product_name, unit_price
FROM products
WHERE unit_price > (
  SELECT avg(unit_price)
  FROM products
  WHERE active = true
)
ORDER BY unit_price DESC;

-- 5. Ordini senza pagamento catturato
SELECT o.order_id, o.order_date, o.status
FROM orders AS o
WHERE o.status <> 'cancelled'
  AND NOT EXISTS (
    SELECT 1
    FROM payments AS p
    WHERE p.order_id = o.order_id
      AND p.status = 'captured'
  )
ORDER BY o.order_id;
