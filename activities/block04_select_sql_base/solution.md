# Soluzione - Blocco 4 - Prime query SQL

## Strategia
1. partire sempre dalla relazione con la granularità richiesta;
2. scrivere query brevi e verificabili una alla volta;
3. usare `CASE` solo dopo aver controllato i valori sorgente;
4. salvare le query finali in `solution.sql`.

## Soluzione completa
```sql
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
```

## Perché la soluzione è corretta
- la tabella scelta ha la granularità giusta;
- i filtri sono leggibili e verificabili;
- le colonne calcolate hanno alias chiari;
- il risultato ha un ordinamento esplicito quando serve.

## Errori da discutere
- scrivere `SELECT *` anche quando servono poche colonne;
- confondere filtro su righe e scelta delle colonne;
- usare `= NULL` invece di `IS NULL`;
- filtrare date con intervalli ambigui;
- ordinare senza gestire i pari merito.

## Checkpoint
- una query base è corretta se la domanda e la granularità sono chiare;
- `WHERE` decide quali righe entrano, `SELECT` decide cosa mostrare;
- un risultato senza ordinamento non va usato come riferimento stabile.
