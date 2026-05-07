# Blocco 5 -- Esercitazioni Docker

    Tema: JOIN, LEFT JOIN, granularità e fan-out

    Caricare lo schema:

    ```bash
    docker exec -i rdsql-postgres psql -U training -d training < sql/01_schema_seed_postgres.sql
    ```

    Eseguire le soluzioni:

    ```bash
    docker exec -i rdsql-postgres psql -U training -d training < activities/block05_join_cardinalita/docker_exercises.sql
    ```

    ## Rappresentazione tabellare

    Tabella o vista di riferimento: `customers + orders + order_items + products`

    | ordine | cliente | prodotto | quantità |
| --- | --- | --- | --- |
| 1 | Alice Bianchi | Laptop 13 Pro | 1 |
| 1 | Alice Bianchi | Laptop Backpack | 1 |
| 2 | Marco Rossi | Laptop 15 Max | 2 |
| 3 | Emma Smith | Monitor 27 | 2 |

    ## Esercizio 1 -- Righe ordine leggibili

        Problema informale: Costruire la query che ricostruisce la tabella ordine-cliente-prodotto-quantità partendo dallo schema normalizzato.

        Soluzione:

        ```sql
        SELECT o.order_id,
       c.full_name,
       p.product_name,
       oi.quantity
FROM order_items AS oi
JOIN orders AS o ON o.order_id = oi.order_id
JOIN customers AS c ON c.customer_id = o.customer_id
JOIN products AS p ON p.product_id = oi.product_id
ORDER BY o.order_id, p.product_name;
        ```

## Esercizio 2 -- Ordini senza spedizione

        Problema informale: Scrivere una query che mostri gli ordini senza spedizione associata.

        Soluzione:

        ```sql
        SELECT o.order_id, o.order_date, c.full_name, o.status
FROM orders AS o
JOIN customers AS c ON c.customer_id = o.customer_id
LEFT JOIN shipments AS s ON s.order_id = o.order_id
WHERE s.shipment_id IS NULL
ORDER BY o.order_date, o.order_id;
        ```

## Esercizio 3 -- Controllo fan-out

        Problema informale: Contare le righe ordine e confrontarle con il numero di ordini.

        Soluzione:

        ```sql
        SELECT count(*) AS orders
FROM orders;

SELECT count(*) AS order_item_rows
FROM orders AS o
JOIN order_items AS oi ON oi.order_id = o.order_id;
        ```
