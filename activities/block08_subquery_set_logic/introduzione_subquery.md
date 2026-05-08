# Blocco 8 -- Gentle Introduction: Subquery e logica insiemistica

    Alcune domande parlano di insiemi: prodotti mai venduti, clienti con almeno un ordine sopra media, ordini senza pagamento.

    Dopo JOIN e aggregazioni, serve un modo per esprimere esistenza, assenza e confronto con insiemi prodotti da altre query.

    ## Sintassi essenziale

    ```sql
    SELECT colonne
FROM tabella_esterna AS e
WHERE EXISTS (
  SELECT 1
  FROM tabella_interna AS i
  WHERE i.chiave = e.chiave
);
    ```

    ## Come leggere la sintassi

    - `EXISTS` verifica che la subquery produca almeno una riga.
- `NOT EXISTS` verifica assenza di righe collegate.
- Una subquery scalare restituisce un valore.
- Una subquery correlata usa colonne della query esterna.
- `UNION`, `INTERSECT`, `EXCEPT` combinano insiemi compatibili.

## Tradurre la frase in quantificatore

- "almeno un ordine" porta naturalmente a `EXISTS`;
- "nessun ordine" porta naturalmente a `NOT EXISTS`;
- "sopra la media" richiede una subquery scalare;
- "presente in A ma non in B" può essere espresso con `EXCEPT`.

## Subquery correlata e non correlata

- Una subquery non correlata non dipende dalla riga esterna.
- Una subquery correlata usa una colonna della query esterna.
- La query esterna resta responsabile della granularità finale.
- `NOT EXISTS` è spesso più robusto di `NOT IN` quando possono comparire `NULL`.

    ## Prodotti mai venduti

```sql
SELECT p.product_id, p.sku, p.product_name
FROM products AS p
WHERE NOT EXISTS (
  SELECT 1
  FROM order_items AS oi
  WHERE oi.product_id = p.product_id
)
ORDER BY p.product_id;
```

## Clienti con ordine sopra la media

```sql
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
```

## Differenza tra insiemi con EXCEPT

```sql
SELECT customer_id
FROM customers
EXCEPT
SELECT customer_id
FROM orders
ORDER BY customer_id;
```

## Subquery scalare

```sql
SELECT product_id, sku, product_name, unit_price
FROM products
WHERE unit_price > (
  SELECT avg(unit_price)
  FROM products
  WHERE active = true
)
ORDER BY unit_price DESC;
```

## Ordini senza pagamento catturato

```sql
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
```

    ## Esercizio con rappresentazione tabellare

    | product_id | sku | in_order_items |
| --- | --- | --- |
| 1 | LAP-13 | yes |
| 16 | WARRANTY-3Y | yes |
| 99 | NEW-SKU | no |

    Richiesta: Date le tabelle prodotti e righe ordine, costruire la query che restituisce i prodotti presenti in catalogo ma mai venduti.

    ## Errori frequenti

    - usare `NOT IN` senza considerare i `NULL`;
- scrivere subquery scalari che restituiscono più righe;
- non distinguere subquery correlata e non correlata;
- nascondere una domanda semplice dietro una subquery troppo complessa;
- dimenticare i filtri di stato anche nella subquery.
