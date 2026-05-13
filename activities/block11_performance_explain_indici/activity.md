# Blocco 11 - Performance di un DBMS per dashboard

## 1. Problema in forma informale
La dashboard sui ticket deve restare reattiva mentre il collector inserisce nuove righe. Bisogna misurare una query, proporre indici coerenti e discutere il trade-off tra letture veloci e scritture più costose.

## 2. Specifica corretta del problema
- input: schema `ticketing` popolato;
- output: piano prima, indice proposto, piano dopo, materialized view e controllo raw-curated;
- vincolo: ogni indice deve avere una query target;
- vincolo: usare `EXPLAIN (ANALYZE, BUFFERS)`;
- vincolo: dichiarare quando una vista materializzata può essere non aggiornata.

## 3. Definizione della soluzione
1. caricare lo schema ticketing;
2. misurare la query dei ticket aperti;
3. creare un indice parziale sui ticket aperti;
4. misurare di nuovo;
5. creare una materialized view giornaliera;
6. verificare raw event e ticket curati.

## 4. Implementazione completa
Caricare prima lo schema nello stack ticketing:

```bash
docker exec rdsql-ticket-postgres psql -U training -d training -v ON_ERROR_STOP=1 -f /sql/ticket_architecture_schema.sql
```

```sql
SET search_path TO ticketing;

EXPLAIN (ANALYZE, BUFFERS)
SELECT ticket_id, opened_at, priority, category, region, status
FROM support_tickets
WHERE status IN ('open', 'assigned', 'waiting_customer')
  AND opened_at >= TIMESTAMP '2026-05-01'
  AND opened_at <  TIMESTAMP '2026-05-14'
ORDER BY opened_at DESC, ticket_id DESC;

CREATE INDEX IF NOT EXISTS idx_ticketing_open_dashboard
ON support_tickets (opened_at DESC, ticket_id DESC)
WHERE status IN ('open', 'assigned', 'waiting_customer');

EXPLAIN (ANALYZE, BUFFERS)
SELECT ticket_id, opened_at, priority, category, region, status
FROM support_tickets
WHERE status IN ('open', 'assigned', 'waiting_customer')
  AND opened_at >= TIMESTAMP '2026-05-01'
  AND opened_at <  TIMESTAMP '2026-05-14'
ORDER BY opened_at DESC, ticket_id DESC;
```

## 5. Criteri di verifica
- il piano prima/dopo è stato letto e commentato;
- l'indice è legato alla query dei ticket aperti;
- il trade-off scrittura/lettura è discusso;
- la materialized view ha una granularità chiara;
- il controllo raw-curated è eseguito.
