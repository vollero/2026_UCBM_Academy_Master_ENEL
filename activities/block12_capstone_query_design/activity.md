# Blocco 12 - Capstone query design

## 1. Problema in forma informale
La direzione chiede un report finale per capire quali paesi e segmenti contribuiscono maggiormente al ricavo, con trend, ranking e controlli di affidabilità.

## 2. Specifica corretta del problema
- input: schema `training`, vista `order_revenue`, clienti e prodotti;
- output: query finale, controlli, breve spiegazione delle assunzioni;
- vincolo: usare CTE per separare passaggi logici;
- vincolo: includere almeno una window function e due query di controllo.

## 3. Definizione della soluzione
1. scrivere prima la specifica in cinque righe;
2. costruire CTE base per ordini validi e ricavi;
3. aggregare alla granularità richiesta;
4. applicare ranking o percentuali con window function;
5. preparare controlli su totali e numero righe.

## 4. Implementazione completa o artefatto atteso
Soluzione caricabile in PostgreSQL dopo lo schema di laboratorio.

```sql
SET search_path TO training;

WITH valid_revenue AS (
    SELECT r.order_id, r.customer_id, r.order_date, r.channel, r.gross_revenue
    FROM order_revenue r
    WHERE r.status NOT IN ('cancelled', 'refunded')
), segment_month AS (
    SELECT date_trunc('month', v.order_date)::date AS month,
           c.segment,
           count(*) AS orders,
           round(sum(v.gross_revenue), 2) AS revenue
    FROM valid_revenue v
    JOIN customers c ON c.customer_id = v.customer_id
    GROUP BY month, c.segment
), ranked AS (
    SELECT month, segment, orders, revenue,
           rank() OVER (PARTITION BY month ORDER BY revenue DESC, segment) AS segment_rank,
           round(100 * revenue / sum(revenue) OVER (PARTITION BY month), 2) AS pct_month_revenue
    FROM segment_month
)
SELECT month, segment, orders, revenue, segment_rank, pct_month_revenue
FROM ranked
WHERE segment_rank <= 3
ORDER BY month, segment_rank, segment;


WITH valid_revenue AS (
    SELECT * FROM order_revenue
    WHERE status NOT IN ('cancelled', 'refunded')
)
SELECT count(*) AS valid_orders,
       round(sum(gross_revenue), 2) AS valid_revenue
FROM valid_revenue;

SELECT count(*) AS customers,
       count(DISTINCT customer_id) AS distinct_customers
FROM customers;
```

## 5. Criteri di verifica
- la specifica è chiara prima del codice;
- ogni CTE ha scopo e granularità leggibili;
- il risultato finale risponde alla domanda dichiarata;
- i controlli confermano popolazione, totali e cardinalità.

## 6. Checkpoint
- il capstone valuta metodo, non solo sintassi;
- una query complessa si costruisce per passaggi verificabili;
- una soluzione professionale dichiara assunzioni, controlli e limiti.
