# Blocco 9 -- Gentle Introduction: CTE, viste e mantenibilità

    Le query reali diventano presto lunghe: join, filtri, aggregazioni e regole business finiscono nello stesso blocco difficile da leggere.

    CTE e viste permettono di dare un nome ai passaggi, come se trasformassimo una spiegazione lunga in paragrafi.

    ## Sintassi essenziale

    ```sql
    WITH nome_passaggio AS (
  SELECT ...
)
SELECT ...
FROM nome_passaggio;
    ```

    ## Come leggere la sintassi

    - `WITH` introduce una o più CTE.
- Ogni CTE dovrebbe avere un nome che spiega il passaggio.
- Una vista salva una query con un nome riusabile.
- Le CTE aiutano a testare una trasformazione alla volta.
- La manutenibilità dipende da nomi, granularità e confini chiari.

    ## Ordini validi come CTE

```sql
WITH valid_orders AS (
  SELECT *
  FROM order_revenue
  WHERE status NOT IN ('cancelled', 'refunded')
)
SELECT channel,
       count(*) AS orders,
       round(sum(gross_revenue), 2) AS revenue
FROM valid_orders
GROUP BY channel
ORDER BY revenue DESC;
```

## Pipeline con più CTE

```sql
WITH valid_orders AS (
  SELECT *
  FROM order_revenue
  WHERE status NOT IN ('cancelled', 'refunded')
),
orders_with_customer AS (
  SELECT r.*, c.country, c.segment
  FROM valid_orders AS r
  JOIN customers AS c ON c.customer_id = r.customer_id
)
SELECT country, segment, count(*) AS orders
FROM orders_with_customer
GROUP BY country, segment
ORDER BY country, segment;
```

## Vista temporanea di sessione

```sql
CREATE TEMP VIEW valid_order_revenue_session AS
SELECT *
FROM order_revenue
WHERE status NOT IN ('cancelled', 'refunded');

SELECT channel, round(sum(gross_revenue), 2) AS revenue
FROM valid_order_revenue_session
GROUP BY channel
ORDER BY revenue DESC;
```

    ## Esercizio con rappresentazione tabellare

    | passaggio | granularità | ruolo |
| --- | --- | --- |
| valid_orders | ordine | filtra stati |
| orders_with_customer | ordine | aggiunge paese |
| country_kpi | paese | calcola KPI |

    Richiesta: Data una query lunga su ordini e clienti, riscriverla con CTE leggibili: ordini validi, ordini con cliente, KPI per paese.

    ## Errori frequenti

    - usare CTE con nomi generici come `tmp1`;
- creare una vista senza documentare la granularità;
- ripetere la stessa logica in molte query;
- mescolare filtro, join e KPI senza passaggi intermedi;
- confondere vista logica e tabella fisica.
