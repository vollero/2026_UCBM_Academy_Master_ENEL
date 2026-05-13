# Soluzione - Blocco 11 - Performance di un DBMS per dashboard

La soluzione misura una query di dashboard, crea un indice parziale coerente con la definizione di ticket aperto, poi introduce una vista materializzata giornaliera.

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
ORDER BY opened_at DESC, ticket_id DESC;

CREATE INDEX IF NOT EXISTS idx_ticketing_open_dashboard
ON support_tickets (opened_at DESC, ticket_id DESC)
WHERE status IN ('open', 'assigned', 'waiting_customer');
```

## Perché è corretta
- l'indice supporta una query reale della dashboard;
- è parziale, quindi non indicizza ticket chiusi inutili per il drill-down operativo;
- la materialized view riduce lavoro ripetuto su metriche giornaliere;
- il controllo raw-curated verifica la pipeline dati.
