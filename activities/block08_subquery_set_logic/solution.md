# Soluzione - Blocco 8 - Subquery e logica insiemistica

## Strategia
1. partire dal soggetto della domanda;
2. scrivere la subquery interna separatamente quando non è correlata;
3. trasformare "non hanno" in `NOT EXISTS`;
4. usare `EXCEPT` per differenze esplicite tra insiemi.

## Soluzione completa
```sql
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
```

## Perché la soluzione è corretta
- il soggetto della query esterna è chiaro;
- il quantificatore business è espresso dalla clausola corretta;
- la subquery è testabile anche da sola quando possibile;
- `NULL` e assenze sono gestiti intenzionalmente.

## Errori da discutere
- usare `NOT IN` senza pensare a `NULL`;
- scrivere subquery che restituiscono più righe dove serve un solo valore;
- non distinguere query correlata e non correlata;
- usare subquery quando un join sarebbe più leggibile;
- dimenticare filtri di stato nella subquery.

## Checkpoint
- subquery e insiemi servono quando la domanda parla di esistenza, assenza o confronto;
- `EXISTS` legge la domanda come "c'è almeno una riga?";
- le assenze vanno trattate con cura per non confondere `NULL` e mancata corrispondenza.
