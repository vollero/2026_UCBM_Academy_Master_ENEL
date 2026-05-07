# Blocco 10 -- Gentle Introduction: Window function

    Vogliamo ranking, totali progressivi e confronti con la riga precedente mantenendo le righe originali.

    GROUP BY comprime righe; le window function aggiungono calcoli mantenendo la granularità di partenza.

    ## Sintassi essenziale

    ```sql
    funzione(...) OVER (
  PARTITION BY gruppo
  ORDER BY ordinamento
) AS nuova_colonna
    ```

    ## Come leggere la sintassi

    - `OVER` trasforma una funzione in funzione finestra.
- `PARTITION BY` definisce gruppi indipendenti.
- `ORDER BY` ordina le righe dentro la finestra.
- `row\_number`, `rank`, `lag` sono funzioni analitiche comuni.
- La query conserva una riga per riga di input.

    ## Ranking ordini per cliente

```sql
SELECT customer_id,
       order_id,
       order_date,
       gross_revenue,
       row_number() OVER (
         PARTITION BY customer_id
         ORDER BY order_date, order_id
       ) AS order_seq
FROM order_revenue
ORDER BY customer_id, order_seq;
```

## Top prodotti per categoria

```sql
SELECT *
FROM (
  SELECT p.category,
         p.product_name,
         sum(oi.quantity) AS units,
         rank() OVER (
           PARTITION BY p.category
           ORDER BY sum(oi.quantity) DESC
         ) AS category_rank
  FROM order_items AS oi
  JOIN products AS p ON p.product_id = oi.product_id
  GROUP BY p.category, p.product_name
) AS ranked
WHERE category_rank <= 3
ORDER BY category, category_rank;
```

## Ricavo progressivo per canale

```sql
SELECT channel,
       order_date,
       order_id,
       gross_revenue,
       sum(gross_revenue) OVER (
         PARTITION BY channel
         ORDER BY order_date, order_id
       ) AS running_revenue
FROM order_revenue
WHERE status NOT IN ('cancelled', 'refunded')
ORDER BY channel, order_date, order_id;
```

    ## Esercizio con rappresentazione tabellare

    | cliente | ordine | data | ricavo |
| --- | --- | --- | --- |
| 1 | 1 | 2025-01-06 | 1418.25 |
| 1 | 15 | 2025-04-03 | 335.00 |
| 1 | 31 | 2025-06-12 | 1470.90 |

    Richiesta: Data la tabella ordini, costruire la query che assegna a ogni ordine il numero progressivo dell'ordine per cliente.

    ## Errori frequenti

    - usare window function quando serve invece un riepilogo con `GROUP BY`;
- dimenticare `ORDER BY` nei calcoli progressivi;
- non distinguere `row\_number` e `rank`;
- non specificare partizioni quando il confronto è per cliente o paese;
- interpretare il totale progressivo senza guardare l'ordinamento.
