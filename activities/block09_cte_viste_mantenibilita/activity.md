# Blocco 9 - CTE, viste e mantenibilità

## 1. Problema in forma informale
Una query KPI è diventata lunga e fragile. Il compito è renderla leggibile e riusabile, senza cambiare il risultato.

## 2. Specifica corretta del problema
- input: query aggregata su ordini, righe e clienti;
- output: versione con CTE e, quando opportuno, vista di supporto;
- vincolo: ogni CTE deve avere responsabilità singola;
- vincolo: la granularità di ogni passaggio va dichiarata in commento o nel nome.

## 3. Definizione della soluzione
1. isolare filtri di validità ordine;
2. isolare calcolo importi di riga;
3. aggregare a ordine prima di aggregare a mese o paese;
4. creare una vista solo per una definizione stabile e riusabile.

## 4. Implementazione completa o artefatto atteso
Soluzione caricabile in PostgreSQL dopo lo schema di laboratorio.

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

## 5. Criteri di verifica
- ogni CTE ha nome, input, output e granularità chiari;
- la query finale si legge dall'alto verso il basso;
- la vista espone una semantica stabile;
- i passaggi intermedi sono testabili singolarmente.

## 6. Checkpoint
- una CTE utile ha un nome che spiega il dato prodotto;
- la mantenibilità si misura dalla facilita con cui un altro lettore verifica la query;
- una vista è un contratto logico: va usata quando la semantica è stabile.
