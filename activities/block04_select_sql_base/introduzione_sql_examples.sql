-- Relational Databases & SQL - Blocco 4
-- Gentle introduction a SQL: esempi eseguibili
-- Prerequisito: caricare ../../sql/01_schema_seed_postgres.sql

SET search_path TO training;

-- 1. SELECT e FROM: una riga per prodotto.
SELECT product_id, sku, product_name, category
FROM products;

-- 2. Alias: nomi più leggibili nel risultato.
SELECT product_name AS nome_prodotto,
       unit_price AS prezzo_unitario
FROM products;

-- 3. WHERE: prodotti con prezzo almeno 500.
SELECT product_id, product_name, unit_price
FROM products
WHERE unit_price >= 500;

-- 4. AND: hardware con prezzo almeno 500.
SELECT product_id, product_name, category, unit_price
FROM products
WHERE category = 'hardware'
  AND unit_price >= 500;

-- 5. IN: stati ordine ammessi.
SELECT order_id, order_date, status
FROM orders
WHERE status IN ('pending', 'shipped', 'refunded');

-- 6. BETWEEN: ordini di marzo 2025.
SELECT order_id, order_date, status
FROM orders
WHERE order_date BETWEEN DATE '2025-03-01'
                     AND DATE '2025-03-31';

-- 7. LIKE: prodotti con Laptop nel nome.
SELECT product_id, product_name
FROM products
WHERE product_name LIKE '%Laptop%';

-- 8. IS NULL: spedizioni non ancora consegnate.
SELECT shipment_id, order_id, shipped_at, delivered_at
FROM shipments
WHERE delivered_at IS NULL;

-- 9. ORDER BY e LIMIT: cinque prodotti più costosi.
SELECT product_id, product_name, unit_price
FROM products
ORDER BY unit_price DESC, product_id
LIMIT 5;

-- 10. Colonna calcolata: importo netto riga ordine.
SELECT order_id, product_id,
       round(quantity * unit_price *
             (1 - discount_pct / 100.0), 2) AS net_amount
FROM order_items;

-- 11. CASE: classificazione fascia prezzo.
SELECT product_id, product_name, unit_price,
       CASE
           WHEN unit_price < 100 THEN 'low'
           WHEN unit_price < 700 THEN 'medium'
           ELSE 'high'
       END AS price_band
FROM products;

-- 12. Query costruita per passaggi: clienti italiani recenti.
SELECT customer_id,
       full_name AS customer_name,
       city,
       segment,
       signup_date
FROM customers
WHERE country = 'IT'
  AND signup_date >= DATE '2025-02-01'
ORDER BY signup_date, customer_id;
