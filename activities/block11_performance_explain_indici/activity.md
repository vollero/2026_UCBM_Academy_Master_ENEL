# Blocco 11 - Performance, EXPLAIN e indici

## 1. Problema in forma informale
Alcune query di report sono lente. Il compito non è creare molti indici, ma proporre pochi indici motivati e dimostrare che cambiano il piano in modo plausibile.

## 2. Specifica corretta del problema
- input: query di ricerca ordini, aggregazioni e join frequenti;
- output: piano prima, indice proposto, piano dopo, commento tecnico;
- vincolo: ogni indice deve citare la query che supporta;
- vincolo: non creare indici generici senza ipotesi verificabile.

## 3. Definizione della soluzione
1. scegliere una query rappresentativa;
2. leggere se il piano fa scan, join costosi o sort espliciti;
3. disegnare indice su colonne di filtro e ordinamento;
4. misurare di nuovo e decidere se l'indice è difendibile.

## 4. Implementazione completa o artefatto atteso
Soluzione caricabile nel container PostgreSQL Docker dopo lo schema di laboratorio.

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

## 5. Criteri di verifica
- ogni indice ha una query che lo giustifica;
- il piano prima e dopo è confrontato;
- si spiegano filtri, join e ordinamenti supportati;
- si riconoscono trade-off e casi in cui l'indice non serve.

## 6. Checkpoint
- performance non significa aggiungere indici a caso;
- un piano va letto rispetto a una query e a una distribuzione dati;
- l'indice migliore è quello che risolve un problema reale con costo accettabile.
