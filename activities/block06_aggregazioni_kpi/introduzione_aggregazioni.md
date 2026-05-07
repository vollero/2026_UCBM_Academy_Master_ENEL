# Blocco 6 -- Gentle Introduction: Aggregazioni e KPI

    Il management chiede indicatori sintetici: ricavo per mese, ordini per canale, valore medio ordine e prodotti più venduti.

    Nel blocco 5 abbiamo ricostruito righe di dettaglio con i JOIN. Ora cambiamo granularità: da molte righe operative a poche righe di sintesi.

    ## Sintassi essenziale

    ```sql
    SELECT colonna_gruppo, funzione_aggregata(colonna) AS metrica
FROM tabella
WHERE filtro_sulle_righe
GROUP BY colonna_gruppo
HAVING filtro_sui_gruppi
ORDER BY colonna_gruppo;
    ```

    ## Come leggere la sintassi

    - `COUNT(*)` conta le righe del gruppo.
- `COUNT(DISTINCT ...)` conta valori distinti.
- `SUM`, `AVG`, `MIN`, `MAX` calcolano misure.
- `WHERE` filtra prima del raggruppamento.
- `HAVING` filtra dopo il raggruppamento.

    ## Ricavo per mese e canale

```sql
SELECT date_trunc('month', order_date)::date AS month,
       channel,
       round(sum(gross_revenue), 2) AS revenue
FROM order_revenue
WHERE status NOT IN ('cancelled', 'refunded')
GROUP BY month, channel
ORDER BY month, channel;
```

## AOV per segmento

```sql
SELECT c.segment,
       count(*) AS valid_orders,
       round(sum(r.gross_revenue), 2) AS revenue,
       round(avg(r.gross_revenue), 2) AS avg_order_value
FROM order_revenue AS r
JOIN customers AS c ON c.customer_id = r.customer_id
WHERE r.status NOT IN ('cancelled', 'refunded')
GROUP BY c.segment
HAVING count(*) >= 2
ORDER BY revenue DESC;
```

## Quantità e ricavo per categoria

```sql
SELECT p.category,
       sum(oi.quantity) AS units,
       round(sum(oi.quantity * oi.unit_price *
                 (1 - oi.discount_pct / 100.0)), 2) AS revenue
FROM order_items AS oi
JOIN products AS p ON p.product_id = oi.product_id
JOIN orders AS o ON o.order_id = oi.order_id
WHERE o.status NOT IN ('cancelled', 'refunded')
GROUP BY p.category
ORDER BY revenue DESC;
```

    ## Esercizio con rappresentazione tabellare

    | mese | canale | ordine | ricavo |
| --- | --- | --- | --- |
| 2025-01 | web | 1 | 1418.25 |
| 2025-01 | sales | 2 | 5074.16 |
| 2025-02 | web | 5 | 568.00 |

    Richiesta: Data la tabella delle righe ordine, costruire la query che produce ricavo e numero ordini per mese e canale, escludendo cancellati e rimborsati.

    ## Errori frequenti

    - contare righe di dettaglio quando si vogliono contare ordini;
- non dichiarare quali stati sono inclusi nel KPI;
- calcolare una media sul denominatore sbagliato;
- dimenticare colonne non aggregate fuori dal `GROUP BY`;
- non verificare se un join ha moltiplicato le righe.
