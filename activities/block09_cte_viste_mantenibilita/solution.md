# Soluzione - Blocco 9 - CTE, viste e mantenibilità

## Strategia
1. isolare filtri di validità ordine;
2. isolare calcolo importi di riga;
3. aggregare a ordine prima di aggregare a mese o paese;
4. creare una vista solo per una definizione stabile e riusabile.

## Soluzione completa
```sql
SET search_path TO training;

CREATE OR REPLACE VIEW valid_order_revenue AS
SELECT r.order_id, r.customer_id, r.order_date, r.channel,
       r.status, r.gross_revenue
FROM order_revenue r
WHERE r.status NOT IN ('cancelled', 'refunded');

WITH monthly_channel AS (
    SELECT date_trunc('month', order_date)::date AS month,
           channel,
           round(sum(gross_revenue), 2) AS revenue
    FROM valid_order_revenue
    GROUP BY month, channel
)
SELECT month, channel, revenue
FROM monthly_channel
ORDER BY month, channel;


WITH customer_revenue AS (
    SELECT customer_id, round(sum(gross_revenue), 2) AS revenue
    FROM valid_order_revenue
    GROUP BY customer_id
), enriched AS (
    SELECT c.customer_id, c.full_name, c.segment,
           coalesce(cr.revenue, 0) AS revenue
    FROM customers c
    LEFT JOIN customer_revenue cr ON cr.customer_id = c.customer_id
)
SELECT *
FROM enriched
ORDER BY revenue DESC, customer_id;
```

## Perché la soluzione è corretta
- ogni CTE ha nome, input, output e granularità chiari;
- la query finale si legge dall'alto verso il basso;
- la vista espone una semantica stabile;
- i passaggi intermedi sono testabili singolarmente.

## Errori da discutere
- usare CTE come contenitore di codice disordinato;
- non controllare la granularità di ogni passaggio;
- creare viste con nomi generici e semantica poco chiara;
- duplicare la stessa definizione KPI in file diversi;
- nascondere filtri business dentro una vista senza documentarli.

## Checkpoint
- una CTE utile ha un nome che spiega il dato prodotto;
- la mantenibilità si misura dalla facilita con cui un altro lettore verifica la query;
- una vista è un contratto logico: va usata quando la semantica è stabile.
