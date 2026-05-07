# Soluzione - Blocco 11 - Performance, EXPLAIN e indici

## Strategia
1. scegliere una query rappresentativa;
2. leggere se il piano fa scan, join costosi o sort espliciti;
3. disegnare indice su colonne di filtro e ordinamento;
4. misurare di nuovo e decidere se l'indice è difendibile.

## Soluzione completa
```sql
SET search_path TO training;

EXPLAIN (ANALYZE, BUFFERS)
SELECT order_id, customer_id, order_date, status
FROM orders
WHERE status = 'completed'
  AND order_date >= DATE '2025-01-01'
  AND order_date <  DATE '2025-07-01'
ORDER BY order_date, order_id;


CREATE INDEX IF NOT EXISTS idx_orders_completed_date
ON orders(order_date, order_id)
WHERE status = 'completed';

EXPLAIN (ANALYZE, BUFFERS)
SELECT order_id, customer_id, order_date, status
FROM orders
WHERE status = 'completed'
  AND order_date >= DATE '2025-01-01'
  AND order_date <  DATE '2025-07-01'
ORDER BY order_date, order_id;

DROP INDEX IF EXISTS idx_orders_completed_date;
```

## Perché la soluzione è corretta
- ogni indice ha una query che lo giustifica;
- il piano prima e dopo è confrontato;
- si spiegano filtri, join e ordinamenti supportati;
- si riconoscono trade-off e casi in cui l'indice non serve.

## Errori da discutere
- creare indici senza una query target;
- misurare una sola esecuzione e trarre conclusioni definitive;
- ignorare costi di scrittura e spazio;
- usare funzioni sulle colonne filtrate rendendo l'indice meno utile;
- non aggiornare statistiche quando il piano sembra incoerente.

## Checkpoint
- performance non significa aggiungere indici a caso;
- un piano va letto rispetto a una query e a una distribuzione dati;
- l'indice migliore è quello che risolve un problema reale con costo accettabile.
