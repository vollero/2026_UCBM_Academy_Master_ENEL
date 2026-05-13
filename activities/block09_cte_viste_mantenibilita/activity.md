# Blocco 9 - Architettura dati containerizzata

## 1. Problema in forma informale
Bisogna preparare il database che alimenterà una dashboard sui ticket di assistenza. Prima di costruire grafici, bisogna distinguere raccolta dati, conservazione nel DBMS, modello relazionale e viste SQL per la dashboard.

## 2. Specifica corretta del problema
- input: script `sql/ticket_architecture_schema.sql`;
- output: schema `ticketing`, tabelle raw/curated, viste `dashboard_*` e query di controllo;
- vincolo: il dato raw non deve essere usato direttamente per i KPI;
- vincolo: ogni vista deve avere granularità dichiarabile;
- vincolo: la soluzione deve essere eseguibile in PostgreSQL.

## 3. Definizione della soluzione
1. caricare lo schema ticketing;
2. controllare sorgenti, raw event e ticket curati;
3. leggere la vista base `dashboard_ticket_base`;
4. leggere la vista giornaliera `dashboard_daily_flow`;
5. spiegare quali viste sono contratti per Metabase.

## 4. Implementazione completa
Soluzione caricabile nel container PostgreSQL Docker.

Caricare prima lo schema nello stack ticketing:

```bash
docker exec rdsql-ticket-postgres psql -U training -d training -v ON_ERROR_STOP=1 -f /sql/ticket_architecture_schema.sql
```

```sql
SET search_path TO ticketing;

SELECT source_id, source_code, description
FROM ticket_sources
ORDER BY source_id;

SELECT count(*) AS raw_events
FROM support_tickets_raw;

SELECT count(*) AS curated_tickets
FROM support_tickets;

SELECT ticket_id,
       source_code,
       external_ticket_id,
       opened_at,
       priority,
       category,
       region,
       status,
       sla_breached
FROM dashboard_ticket_base
ORDER BY opened_at
LIMIT 10;

SELECT day, opened_tickets, resolved_tickets, backlog_delta
FROM dashboard_daily_flow
ORDER BY day;

SELECT (SELECT count(*) FROM support_tickets_raw) AS raw_events,
       (SELECT count(*) FROM support_tickets) AS curated_tickets,
       (SELECT count(*)
        FROM support_tickets_raw r
        LEFT JOIN support_tickets t
          ON t.external_ticket_id = r.external_ticket_id
        WHERE t.ticket_id IS NULL) AS raw_without_curated_ticket;
```

## 5. Criteri di verifica
- raw event e ticket curati sono presenti;
- la vista base ha una riga per ticket;
- la vista giornaliera ha una riga per giorno;
- il controllo raw-curated non segnala ticket raw non trasformati;
- le viste sono adatte a essere interrogate da Metabase.
