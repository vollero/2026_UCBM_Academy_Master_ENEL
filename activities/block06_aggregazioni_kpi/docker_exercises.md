# Blocco 6 -- Esercitazioni Docker

    Tema: GROUP BY, COUNT, SUM, AVG, HAVING

    Caricare lo schema:

    ```bash
    docker exec -i rdsql-postgres psql -U training -d training < sql/01_schema_seed_postgres.sql
    ```

    Eseguire le soluzioni:

    ```bash
    docker exec -i rdsql-postgres psql -U training -d training < activities/block06_aggregazioni_kpi/docker_exercises.sql
    ```

    ## Rappresentazione tabellare

    Tabella o vista di riferimento: `order_revenue`

    | order_id | month | channel | status | gross_revenue |
| --- | --- | --- | --- | --- |
| 1 | 2025-01 | web | completed | 1418.25 |
| 2 | 2025-01 | sales | completed | 5074.16 |
| 8 | 2025-02 | sales | cancelled | 5997.00 |
| 10 | 2025-03 | partner | shipped | 1362.80 |

    ## Esercizio 1 -- Ricavo per mese e canale

        Problema informale: Scrivere la query che calcola ricavo e numero ordini per mese e canale, escludendo cancellati e rimborsati.

        Soluzione:

        ```sql
        SELECT date_trunc('month', order_date)::date AS month,
       channel,
       count(*) AS orders,
       round(sum(gross_revenue), 2) AS revenue
FROM order_revenue
WHERE status NOT IN ('cancelled', 'refunded')
GROUP BY month, channel
ORDER BY month, channel;
        ```

## Esercizio 2 -- AOV per segmento

        Problema informale: Scrivere la query che calcola valore medio ordine per segmento cliente.

        Soluzione:

        ```sql
        SELECT c.segment,
       count(*) AS valid_orders,
       round(avg(r.gross_revenue), 2) AS avg_order_value
FROM order_revenue AS r
JOIN customers AS c ON c.customer_id = r.customer_id
WHERE r.status NOT IN ('cancelled', 'refunded')
GROUP BY c.segment
ORDER BY avg_order_value DESC;
        ```

## Esercizio 3 -- Categorie con almeno 10 unità

        Problema informale: Scrivere la query che mostra categorie con almeno 10 unità vendute valide.

        Soluzione:

        ```sql
        SELECT p.category,
       sum(oi.quantity) AS units
FROM order_items AS oi
JOIN products AS p ON p.product_id = oi.product_id
JOIN orders AS o ON o.order_id = oi.order_id
WHERE o.status NOT IN ('cancelled', 'refunded')
GROUP BY p.category
HAVING sum(oi.quantity) >= 10
ORDER BY units DESC;
        ```
