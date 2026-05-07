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
