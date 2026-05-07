# Blocco 10 - Window function

## 1. Problema in forma informale
Il management vuole leggere classifiche e trend: ranking dei paesi per mese, ricavo cumulato, confronto con mese precedente e quota percentuale del totale.

## 2. Specifica corretta del problema
- input: aggregati di vendita validi;
- output: query con window function e colonne di confronto;
- vincolo: mantenere il dettaglio richiesto, non collassare righe inutilmente;
- vincolo: ogni finestra deve dichiarare partizione e ordinamento quando rilevanti.

## 3. Definizione della soluzione
1. costruire CTE base con ricavo mensile;
2. applicare ranking per partizione mensile;
3. usare `sum(...) OVER` per cumulati;
4. usare `lag` per confronto col periodo precedente.

## 4. Implementazione completa o artefatto atteso
Soluzione caricabile in PostgreSQL dopo lo schema di laboratorio.

```sql
SET search_path TO training;

WITH country_month AS (
    SELECT date_trunc('month', r.order_date)::date AS month,
           c.country,
           round(sum(r.gross_revenue), 2) AS revenue
    FROM order_revenue r
    JOIN customers c ON c.customer_id = r.customer_id
    WHERE r.status NOT IN ('cancelled', 'refunded')
    GROUP BY month, c.country
)
SELECT month, country, revenue,
       rank() OVER (PARTITION BY month ORDER BY revenue DESC, country) AS country_rank,
       round(100 * revenue / sum(revenue) OVER (PARTITION BY month), 2) AS pct_month
FROM country_month
ORDER BY month, country_rank, country;


WITH monthly_channel AS (
    SELECT date_trunc('month', order_date)::date AS month,
           channel,
           round(sum(gross_revenue), 2) AS revenue
    FROM order_revenue
    WHERE status NOT IN ('cancelled', 'refunded')
    GROUP BY month, channel
)
SELECT month, channel, revenue,
       sum(revenue) OVER (PARTITION BY channel ORDER BY month
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_revenue,
       lag(revenue) OVER (PARTITION BY channel ORDER BY month) AS previous_month_revenue
FROM monthly_channel
ORDER BY channel, month;
```

## 5. Criteri di verifica
- la relazione base ha la granularità giusta;
- partizione e ordinamento sono coerenti con la domanda;
- il numero di righe finali è quello atteso;
- i pari merito sono trattati intenzionalmente.

## 6. Checkpoint
- una window function arricchisce righe, non le raggruppa;
- partizione e ordinamento sono parte della semantica, non dettagli opzionali;
- prima si costruisce la relazione base, poi si applica la finestra.
