# Query SQL Per Copia E Incolla

Questa guida raccoglie query pronte per la dimostrazione in aula: cancellazione di database e tabelle, creazione di tabelle, inserimento dati, `JOIN` e raggruppamenti.

Gli esempi usano un database separato, `query_copy_paste_lab`, per non modificare il database di laboratorio `training`.

## Eseguire Lo Script Completo

Dalla cartella principale della repository:

```bash
docker exec -i rdsql-postgres psql -U training -d postgres < sql/query_copia_incolla.sql
```

Entrare nel database demo:

```bash
docker exec -it rdsql-postgres psql -U training -d query_copy_paste_lab
```

Dentro `psql`:

```sql
SET search_path TO copylab;
\dt
```

## Cancellare E Creare Un Database

Da eseguire connessi al database `postgres`, non al database che si vuole cancellare.

```sql
\connect postgres
DROP DATABASE IF EXISTS query_copy_paste_lab WITH (FORCE);
CREATE DATABASE query_copy_paste_lab;
\connect query_copy_paste_lab
```

## Creare Uno Schema Di Lavoro

```sql
CREATE SCHEMA IF NOT EXISTS copylab;
SET search_path TO copylab;
```

## Cancellare Tabelle

Quando ci sono foreign key, cancellare prima le tabelle figlie e poi le tabelle padre.

```sql
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;
```

Alternativa rapida per cancellare tutto lo schema:

```sql
DROP SCHEMA IF EXISTS copylab CASCADE;
CREATE SCHEMA copylab;
SET search_path TO copylab;
```

## Svuotare Tabelle Senza Cancellarle

```sql
TRUNCATE TABLE payments, order_items, orders RESTART IDENTITY CASCADE;
```

## Creare Tabelle

```sql
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
```

## Inserire Dati

```sql
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
```

## Inserimento Singolo Con RETURNING

```sql
INSERT INTO customers (customer_id, full_name, city, segment)
VALUES (7, 'Test Temporaneo', 'Firenze', 'consumer')
RETURNING *;
```

## Cancellare Righe

```sql
DELETE FROM payments
WHERE order_id = 108;

DELETE FROM order_items
WHERE order_id = 108;

DELETE FROM orders
WHERE order_id = 108;
```

Esempio sicuro in transazione:

```sql
BEGIN;

DELETE FROM payments
WHERE order_id = 108
RETURNING *;

DELETE FROM order_items
WHERE order_id = 108
RETURNING *;

DELETE FROM orders
WHERE order_id = 108
RETURNING *;

ROLLBACK;
```

## JOIN Base: Ordini Con Clienti

```sql
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
```

## JOIN A Più Tabelle: Report Righe Ordine

```sql
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
```

## LEFT JOIN: Clienti Anche Senza Ordini

```sql
SELECT
    c.customer_id,
    c.full_name,
    o.order_id,
    o.status
FROM customers AS c
LEFT JOIN orders AS o
    ON o.customer_id = c.customer_id
ORDER BY c.customer_id, o.order_id;
```

## LEFT JOIN: Ordini Anche Senza Pagamento

```sql
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
```

## Raggruppamento: Numero Ordini Per Stato

```sql
SELECT
    status,
    COUNT(*) AS orders_count
FROM orders
GROUP BY status
ORDER BY status;
```

## Raggruppamento Con JOIN: Fatturato Per Categoria

```sql
SELECT
    p.category,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100)), 2) AS net_revenue
FROM order_items AS oi
JOIN products AS p
    ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY net_revenue DESC;
```

## Raggruppamento Per Cliente

```sql
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
```

## HAVING: Prodotti Con Almeno 3 Unità Vendute

```sql
SELECT
    p.product_name,
    SUM(oi.quantity) AS units_sold
FROM order_items AS oi
JOIN products AS p
    ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
HAVING SUM(oi.quantity) >= 3
ORDER BY units_sold DESC;
```

## Raggruppamento Per Mese

```sql
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
```

## ROLLUP: Totali Per Categoria E Totale Generale

```sql
SELECT
    COALESCE(p.category, 'TOTALE') AS category,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100)), 2) AS net_revenue
FROM order_items AS oi
JOIN products AS p
    ON p.product_id = oi.product_id
GROUP BY ROLLUP (p.category)
ORDER BY p.category NULLS LAST;
```

## Pulizia Finale

Da eseguire se si vuole eliminare completamente il database demo.

```sql
\connect postgres
DROP DATABASE IF EXISTS query_copy_paste_lab WITH (FORCE);
```
