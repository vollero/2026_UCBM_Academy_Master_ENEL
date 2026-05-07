# Blocco 4 -- Esercitazioni Docker

    Tema: SELECT, WHERE, ORDER BY, LIMIT, CASE

    Caricare lo schema:

    ```bash
    docker exec -i rdsql-postgres psql -U training -d training < sql/01_schema_seed_postgres.sql
    ```

    Eseguire le soluzioni:

    ```bash
    docker exec -i rdsql-postgres psql -U training -d training < activities/block04_select_sql_base/docker_exercises.sql
    ```

    ## Rappresentazione tabellare

    Tabella o vista di riferimento: `products`

    | product_id | sku | product_name | category | unit_price | active |
| --- | --- | --- | --- | --- | --- |
| 1 | LAP-13 | Laptop 13 Pro | hardware | 1199.00 | true |
| 4 | KEY-MECH | Mechanical Keyboard | accessories | 99.00 | true |
| 8 | LIC-STD | Analytics Suite Standard | software | 39.00 | true |
| 11 | SRV-SQL | SQL Performance Review | services | 900.00 | true |

    ## Esercizio 1 -- Prodotti hardware costosi

        Problema informale: Scrivere una query che mostri i prodotti hardware con prezzo almeno 500, ordinati per prezzo decrescente.

        Soluzione:

        ```sql
        SELECT product_id, sku, product_name, unit_price
FROM products
WHERE category = 'hardware'
  AND unit_price >= 500
ORDER BY unit_price DESC, product_id;
        ```

## Esercizio 2 -- Fascia prezzo

        Problema informale: Scrivere una query che assegni una fascia low/medium/high ai prodotti in base al prezzo.

        Soluzione:

        ```sql
        SELECT product_id, product_name, unit_price,
       CASE
         WHEN unit_price < 100 THEN 'low'
         WHEN unit_price < 700 THEN 'medium'
         ELSE 'high'
       END AS price_band
FROM products
ORDER BY unit_price, product_id;
        ```

## Esercizio 3 -- Top 5 prodotti

        Problema informale: Scrivere una query che mostri i cinque prodotti più costosi.

        Soluzione:

        ```sql
        SELECT product_id, sku, product_name, unit_price
FROM products
WHERE active = true
ORDER BY unit_price DESC, product_id
LIMIT 5;
        ```
