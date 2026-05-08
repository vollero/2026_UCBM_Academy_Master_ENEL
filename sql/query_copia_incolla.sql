-- Relational Databases & SQL
-- Query di copia/incolla per laboratorio PostgreSQL in Docker
--
-- Esecuzione consigliata dalla cartella principale della repository:
-- docker exec -i rdsql-postgres psql -U training -d postgres < sql/query_copia_incolla.sql
--
-- Nota: questo file usa comandi psql come \connect e \echo.
-- Non modifica il database training: crea e usa il database query_copy_paste_lab.

\set ON_ERROR_STOP on

\echo '1. Reset del database demo'
\connect postgres
DROP DATABASE IF EXISTS query_copy_paste_lab WITH (FORCE);
CREATE DATABASE query_copy_paste_lab;
\connect query_copy_paste_lab

\echo '2. Creazione schema e tabelle'
CREATE SCHEMA IF NOT EXISTS copylab;
SET search_path TO copylab;

DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id integer PRIMARY KEY,
    full_name text NOT NULL,
    city text NOT NULL,
    segment text NOT NULL CHECK (segment IN ('consumer', 'smb', 'enterprise'))
);

CREATE TABLE products (
    product_id integer PRIMARY KEY,
    sku text NOT NULL UNIQUE,
    product_name text NOT NULL,
    category text NOT NULL,
    unit_price numeric(10, 2) NOT NULL CHECK (unit_price >= 0)
);

CREATE TABLE orders (
    order_id integer PRIMARY KEY,
    customer_id integer NOT NULL REFERENCES customers(customer_id),
    order_date date NOT NULL,
    status text NOT NULL CHECK (status IN ('pending', 'completed', 'shipped', 'cancelled', 'refunded')),
    channel text NOT NULL CHECK (channel IN ('web', 'sales', 'marketplace', 'partner'))
);

CREATE TABLE order_items (
    order_id integer NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id integer NOT NULL REFERENCES products(product_id),
    quantity integer NOT NULL CHECK (quantity > 0),
    unit_price numeric(10, 2) NOT NULL CHECK (unit_price >= 0),
    discount_pct numeric(5, 2) NOT NULL DEFAULT 0 CHECK (discount_pct >= 0 AND discount_pct < 100),
    PRIMARY KEY (order_id, product_id)
);

CREATE TABLE payments (
    payment_id integer PRIMARY KEY,
    order_id integer NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    paid_at timestamp NOT NULL,
    amount numeric(10, 2) NOT NULL CHECK (amount >= 0),
    method text NOT NULL CHECK (method IN ('card', 'bank_transfer', 'paypal', 'invoice')),
    status text NOT NULL CHECK (status IN ('authorized', 'captured', 'failed', 'refunded'))
);

\echo '3. Inserimento dati'
INSERT INTO customers (customer_id, full_name, city, segment) VALUES
(1, 'Alice Bianchi', 'Roma', 'consumer'),
(2, 'Marco Rossi', 'Milano', 'smb'),
(3, 'Giulia Verdi', 'Torino', 'consumer'),
(4, 'Luca Neri', 'Bologna', 'enterprise'),
(5, 'Sara Gallo', 'Napoli', 'consumer'),
(6, 'Cliente Senza Ordini', 'Palermo', 'smb');

INSERT INTO products (product_id, sku, product_name, category, unit_price) VALUES
(1, 'LAP-13', 'Laptop 13 Pro', 'hardware', 1199.00),
(2, 'MON-27', 'Monitor 27', 'hardware', 329.00),
(3, 'KEY-MECH', 'Mechanical Keyboard', 'accessories', 99.00),
(4, 'MOU-WL', 'Wireless Mouse', 'accessories', 39.00),
(5, 'LIC-STD', 'Analytics Suite Standard', 'software', 39.00),
(6, 'SRV-SETUP', 'Onboarding Workshop', 'services', 650.00),
(7, 'WARRANTY-3Y', 'Extended Warranty 3Y', 'services', 199.00);

INSERT INTO orders (order_id, customer_id, order_date, status, channel) VALUES
(101, 1, '2026-01-10', 'completed', 'web'),
(102, 1, '2026-01-15', 'shipped', 'web'),
(103, 2, '2026-01-20', 'completed', 'sales'),
(104, 3, '2026-02-02', 'cancelled', 'web'),
(105, 4, '2026-02-10', 'completed', 'sales'),
(106, 2, '2026-02-18', 'pending', 'partner'),
(107, 5, '2026-03-01', 'completed', 'marketplace'),
(108, 4, '2026-03-05', 'refunded', 'sales');

INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(101, 1, 1, 1199.00, 5),
(101, 7, 1, 199.00, 10),
(102, 2, 2, 329.00, 0),
(102, 3, 1, 99.00, 0),
(103, 1, 3, 1199.00, 8),
(103, 6, 1, 650.00, 0),
(104, 4, 2, 39.00, 0),
(105, 1, 5, 1199.00, 12),
(105, 5, 20, 39.00, 15),
(106, 2, 1, 329.00, 0),
(107, 3, 2, 99.00, 0),
(107, 4, 2, 39.00, 0),
(108, 6, 1, 650.00, 0);

INSERT INTO payments (payment_id, order_id, paid_at, amount, method, status) VALUES
(1001, 101, '2026-01-10 10:15:00', 1318.15, 'card', 'captured'),
(1002, 102, '2026-01-15 16:30:00', 757.00, 'paypal', 'authorized'),
(1003, 103, '2026-01-20 12:05:00', 3959.24, 'invoice', 'captured'),
(1004, 104, '2026-02-02 09:10:00', 0.00, 'card', 'failed'),
(1005, 105, '2026-02-10 14:40:00', 6055.60, 'bank_transfer', 'captured'),
(1006, 107, '2026-03-01 18:00:00', 276.00, 'card', 'captured'),
(1007, 108, '2026-03-05 11:20:00', 650.00, 'invoice', 'refunded');

\echo '4. Controlli rapidi'
SELECT COUNT(*) AS customers_count FROM customers;
SELECT COUNT(*) AS products_count FROM products;
SELECT COUNT(*) AS orders_count FROM orders;
SELECT COUNT(*) AS order_items_count FROM order_items;
SELECT COUNT(*) AS payments_count FROM payments;

\echo '5. Esempi JOIN'
SELECT
    o.order_id,
    o.order_date,
    c.full_name,
    c.city,
    o.status
FROM orders AS o
JOIN customers AS c
    ON c.customer_id = o.customer_id
ORDER BY o.order_id;

SELECT
    o.order_id,
    c.full_name,
    p.sku,
    p.product_name,
    oi.quantity,
    oi.unit_price
FROM orders AS o
JOIN customers AS c
    ON c.customer_id = o.customer_id
JOIN order_items AS oi
    ON oi.order_id = o.order_id
JOIN products AS p
    ON p.product_id = oi.product_id
ORDER BY o.order_id, p.sku;

SELECT
    c.customer_id,
    c.full_name,
    o.order_id,
    o.status
FROM customers AS c
LEFT JOIN orders AS o
    ON o.customer_id = c.customer_id
ORDER BY c.customer_id, o.order_id;

SELECT
    o.order_id,
    o.status AS order_status,
    p.payment_id,
    p.status AS payment_status,
    p.amount
FROM orders AS o
LEFT JOIN payments AS p
    ON p.order_id = o.order_id
ORDER BY o.order_id;

\echo '6. Esempi GROUP BY'
SELECT
    status,
    COUNT(*) AS orders_count
FROM orders
GROUP BY status
ORDER BY status;

SELECT
    p.category,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100)), 2) AS net_revenue
FROM order_items AS oi
JOIN products AS p
    ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY net_revenue DESC;

SELECT
    c.full_name,
    COUNT(DISTINCT o.order_id) AS orders_count,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100)), 2) AS net_revenue
FROM customers AS c
JOIN orders AS o
    ON o.customer_id = c.customer_id
JOIN order_items AS oi
    ON oi.order_id = o.order_id
WHERE o.status IN ('completed', 'shipped')
GROUP BY c.customer_id, c.full_name
ORDER BY net_revenue DESC;

SELECT
    p.product_name,
    SUM(oi.quantity) AS units_sold
FROM order_items AS oi
JOIN products AS p
    ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
HAVING SUM(oi.quantity) >= 3
ORDER BY units_sold DESC;

SELECT
    date_trunc('month', o.order_date)::date AS month,
    COUNT(*) AS orders_count,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100)), 2) AS net_revenue
FROM orders AS o
JOIN order_items AS oi
    ON oi.order_id = o.order_id
WHERE o.status <> 'cancelled'
GROUP BY date_trunc('month', o.order_date)
ORDER BY month;

\echo '7. INSERT e DELETE in transazione con ROLLBACK'
BEGIN;

INSERT INTO customers (customer_id, full_name, city, segment)
VALUES (7, 'Test Temporaneo', 'Firenze', 'consumer')
RETURNING *;

DELETE FROM customers
WHERE customer_id = 7
RETURNING *;

ROLLBACK;

\echo '8. TRUNCATE in transazione con ROLLBACK'
BEGIN;

TRUNCATE TABLE payments, order_items, orders RESTART IDENTITY CASCADE;

SELECT COUNT(*) AS orders_after_truncate FROM orders;

ROLLBACK;

SELECT COUNT(*) AS orders_after_rollback FROM orders;

\echo '9. Query distruttive da copiare solo quando servono'
-- Cancellare righe rispettando le foreign key:
-- DELETE FROM payments WHERE order_id = 108;
-- DELETE FROM order_items WHERE order_id = 108;
-- DELETE FROM orders WHERE order_id = 108;
--
-- Svuotare tabelle:
-- TRUNCATE TABLE payments, order_items, orders RESTART IDENTITY CASCADE;
--
-- Cancellare tabelle in ordine sicuro:
-- DROP TABLE IF EXISTS payments;
-- DROP TABLE IF EXISTS order_items;
-- DROP TABLE IF EXISTS orders;
-- DROP TABLE IF EXISTS products;
-- DROP TABLE IF EXISTS customers;
--
-- Cancellare schema e tutto il suo contenuto:
-- DROP SCHEMA IF EXISTS copylab CASCADE;
--
-- Cancellare il database demo:
-- \connect postgres
-- DROP DATABASE IF EXISTS query_copy_paste_lab WITH (FORCE);
