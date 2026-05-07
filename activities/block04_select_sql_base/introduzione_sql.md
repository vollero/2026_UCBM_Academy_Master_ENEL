# Blocco 4 - Gentle Introduction a SQL

Materiale aggiuntivo per introdurre gradualmente la sintassi delle prime query SQL.

## Idea generale

Una query SQL è una domanda posta a una relazione.

- `FROM`: relazione di partenza.
- `WHERE`: righe da tenere.
- `SELECT`: colonne da mostrare o calcolare.
- `ORDER BY`: ordine di lettura del risultato.
- `LIMIT`: numero massimo di righe finali.

## SELECT e FROM

Sintassi:

```sql
SELECT colonna_1, colonna_2
FROM tabella;
```

Esempio:

```sql
SELECT product_id, sku, product_name, category
FROM products;
```

La granularità del risultato è una riga per prodotto, perché la tabella sorgente è `products`.

## WHERE

```sql
SELECT product_id, product_name, unit_price
FROM products
WHERE unit_price >= 500;
```

```sql
SELECT product_id, product_name, category, unit_price
FROM products
WHERE category = 'hardware'
  AND unit_price >= 500;
```

`WHERE` lavora sulle righe: ogni riga passa solo se la condizione è vera.

## IN, BETWEEN, LIKE

```sql
SELECT order_id, order_date, status
FROM orders
WHERE status IN ('pending', 'shipped', 'refunded');
```

```sql
SELECT order_id, order_date, status
FROM orders
WHERE order_date BETWEEN DATE '2025-03-01'
                     AND DATE '2025-03-31';
```

```sql
SELECT product_id, product_name
FROM products
WHERE product_name LIKE '%Laptop%';
```

## NULL

Errore comune:

```sql
SELECT shipment_id, order_id
FROM shipments
WHERE delivered_at = NULL;
```

Forma corretta:

```sql
SELECT shipment_id, order_id, shipped_at, delivered_at
FROM shipments
WHERE delivered_at IS NULL;
```

## ORDER BY e LIMIT

```sql
SELECT product_id, product_name, unit_price
FROM products
ORDER BY unit_price DESC, product_id
LIMIT 5;
```

`LIMIT` ha senso solo quando l'ordinamento è dichiarato.

## Colonne calcolate e CASE

```sql
SELECT order_id, product_id,
       round(quantity * unit_price *
             (1 - discount_pct / 100.0), 2) AS net_amount
FROM order_items;
```

```sql
SELECT product_id, product_name, unit_price,
       CASE
           WHEN unit_price < 100 THEN 'low'
           WHEN unit_price < 700 THEN 'medium'
           ELSE 'high'
       END AS price_band
FROM products;
```

## Query costruita per passaggi

Domanda: mostrare i clienti italiani registrati da febbraio 2025 in poi, con nome, città, segmento e data di registrazione, ordinati per data.

```sql
SELECT customer_id,
       full_name AS customer_name,
       city,
       segment,
       signup_date
FROM customers
WHERE country = 'IT'
  AND signup_date >= DATE '2025-02-01'
ORDER BY signup_date, customer_id;
```

## Richiami ai casi del blocco 3

Energia, schema concettuale:

```sql
SELECT reading_id, month, kwh, quality
FROM energy_readings
WHERE quality <> 'valid'
ORDER BY month, reading_id;
```

Monitoraggio ambientale, schema concettuale:

```sql
SELECT measurement_id, measured_at, value, quality_flag
FROM measurements
WHERE value > 40
ORDER BY measured_at, measurement_id;
```

## Checklist

- La relazione scelta ha la granularità giusta?
- Le colonne sono esplicite?
- I filtri corrispondono alla domanda?
- I valori mancanti sono trattati con `IS NULL` o `IS NOT NULL`?
- Le colonne calcolate hanno alias chiari?
- L'ordinamento è dichiarato quando serve?
