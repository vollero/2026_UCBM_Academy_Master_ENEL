# Blocco 8 -- Esercitazioni Docker

    Tema: EXISTS, NOT EXISTS, subquery scalari, EXCEPT

    Caricare lo schema:

    ```bash
    docker exec -i rdsql-postgres psql -U training -d training < sql/01_schema_seed_postgres.sql
    ```

    Eseguire le soluzioni:

    ```bash
    docker exec -i rdsql-postgres psql -U training -d training < activities/block08_subquery_set_logic/docker_exercises.sql
    ```

    ## Rappresentazione tabellare

    Tabella o vista di riferimento: `products + order_items`

    | product_id | sku | venduto? |
| --- | --- | --- |
| 1 | LAP-13 | yes |
| 2 | LAP-15 | yes |
| 16 | WARRANTY-3Y | yes |
| 99 | NEW-SKU | no |

    ## Esercizio 1 -- Prodotti mai venduti

        Problema informale: Scrivere la query che mostra i prodotti presenti in catalogo ma mai venduti.

        Soluzione:

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

## Esercizio 2 -- Clienti con ordini sopra media

        Problema informale: Scrivere la query che mostra clienti con almeno un ordine valido sopra la media degli ordini validi.

        Soluzione:

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

## Esercizio 3 -- Clienti senza ordini con EXCEPT

        Problema informale: Scrivere la differenza tra tutti i clienti e i clienti presenti negli ordini.

        Soluzione:

        ```sql
        SELECT customer_id
FROM customers
EXCEPT
SELECT customer_id
FROM orders
ORDER BY customer_id;
        ```
