# Blocco 12 -- Gentle Introduction: Capstone query design

    Una richiesta reale mescola modello, join, filtri, KPI, subquery e leggibilità. Serve un metodo completo.

    Il capstone integra tutto: granularità, chiavi, JOIN, aggregazioni, CTE, controlli e spiegazione della soluzione.

    ## Sintassi essenziale

    ```sql
    WITH passaggio_1 AS (...),
passaggio_2 AS (...),
risultato AS (...)
SELECT ...
FROM risultato
ORDER BY ...;
    ```

    ## Come leggere la sintassi

    - Tradurre la domanda informale in specifica controllabile.
- Separare popolazione, join, metriche e output.
- Usare CTE per rendere visibile il ragionamento.
- Aggiungere query di controllo.
- Spiegare limiti e assunzioni della soluzione.

    ## Specifica in CTE

```sql
WITH valid_orders AS (
  SELECT *
  FROM order_revenue
  WHERE status NOT IN ('cancelled', 'refunded')
),
customer_kpi AS (
  SELECT c.customer_id,
         c.full_name,
         c.segment,
         count(*) AS orders,
         round(sum(v.gross_revenue), 2) AS revenue
  FROM valid_orders AS v
  JOIN customers AS c ON c.customer_id = v.customer_id
  GROUP BY c.customer_id, c.full_name, c.segment
)
SELECT *
FROM customer_kpi
WHERE revenue >= 1000
ORDER BY revenue DESC;
```

## Controllo del denominatore

```sql
WITH valid_orders AS (
  SELECT *
  FROM order_revenue
  WHERE status NOT IN ('cancelled', 'refunded')
)
SELECT count(*) AS valid_orders,
       count(DISTINCT customer_id) AS customers,
       round(sum(gross_revenue), 2) AS revenue
FROM valid_orders;
```

## Report finale per paese e segmento

```sql
WITH valid_orders AS (
  SELECT *
  FROM order_revenue
  WHERE status NOT IN ('cancelled', 'refunded')
),
enriched AS (
  SELECT v.*, c.country, c.segment
  FROM valid_orders AS v
  JOIN customers AS c ON c.customer_id = v.customer_id
)
SELECT country, segment,
       count(*) AS orders,
       round(sum(gross_revenue), 2) AS revenue,
       round(avg(gross_revenue), 2) AS aov
FROM enriched
GROUP BY country, segment
ORDER BY country, revenue DESC;
```

    ## Esercizio con rappresentazione tabellare

    | richiesta | decisione |
| --- | --- |
| clienti ad alto valore | granularità cliente |
| ordini validi | escludere cancelled/refunded |
| KPI | ordini, ricavo, AOV |

    Richiesta: Data una richiesta business informale, costruire specifica, CTE intermedie, query finale e controlli di validazione.

    ## Errori frequenti

    - partire subito dal codice senza specifica;
- non dichiarare granularità e popolazione;
- mescolare troppe regole in una sola SELECT;
- non verificare conteggi e totali intermedi;
- presentare una query corretta ma non spiegabile.
