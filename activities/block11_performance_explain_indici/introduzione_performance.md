# Blocco 11 -- Gentle Introduction: Performance, EXPLAIN e indici

    Una query corretta può essere lenta. Serve capire come il DBMS la esegue e quali indici aiutano davvero.

    Dopo aver imparato a scrivere query, impariamo a osservare il lavoro svolto dal motore.

    ## Sintassi essenziale

    ```sql
    EXPLAIN (ANALYZE, BUFFERS)
SELECT ...
FROM ...
WHERE ...;
    ```

    ## Come leggere la sintassi

    - `EXPLAIN` mostra il piano stimato.
- `EXPLAIN ANALYZE` esegue la query e misura.
- Un indice aiuta quando il filtro è selettivo e frequente.
- Gli indici hanno costo su scritture e spazio.
- La performance si valuta con un caso d'uso, non in astratto.

    ## Piano di una query filtrata

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT order_id, order_date, status
FROM orders
WHERE customer_id = 1
ORDER BY order_date;
```

## Indice candidato

```sql
BEGIN;

CREATE INDEX idx_orders_customer_date
ON orders (customer_id, order_date);

EXPLAIN (ANALYZE, BUFFERS)
SELECT order_id, order_date, status
FROM orders
WHERE customer_id = 1
ORDER BY order_date;

ROLLBACK;
```

## Indice per join frequente

```sql
BEGIN;

CREATE INDEX idx_order_items_product
ON order_items (product_id);

EXPLAIN (ANALYZE, BUFFERS)
SELECT p.product_name, sum(oi.quantity) AS units
FROM order_items AS oi
JOIN products AS p ON p.product_id = oi.product_id
GROUP BY p.product_name;

ROLLBACK;
```

    ## Esercizio con rappresentazione tabellare

    | query | filtro | ordinamento |
| --- | --- | --- |
| ordini cliente | customer_id | order_date |
| righe prodotto | product_id | none |
| spedizioni aperte | delivered_at IS NULL | shipped_at |

    Richiesta: Data una query frequente con filtro su cliente e ordinamento per data, proporre un indice e verificarlo con EXPLAIN.

    ## Errori frequenti

    - creare indici su ogni colonna senza motivo;
- valutare una query solo su dataset minuscoli;
- ignorare differenza tra stima e righe reali;
- dimenticare che funzioni sulle colonne possono impedire l'uso efficace dell'indice;
- ottimizzare prima di avere una query corretta e misurata.
