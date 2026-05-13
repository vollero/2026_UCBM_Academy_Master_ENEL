# Materiali NoSQL

Questa cartella contiene gli script MongoDB per i blocchi 15-16.

## Avvio stack

```bash
docker compose -f docker-compose.telemetry.yml up -d
```

## Script principali

- `telemetry_schema.js`: ricrea il database `telemetry`, carica dati iniziali e crea indici.
- `telemetry_collector_tick.js`: inserisce una lettura simulata e un eventuale alert.
- `telemetry_dashboard_queries.js`: esegue aggregation pipeline per KPI, trend, energia, ambiente, alert e controlli.

## Esecuzione

```bash
docker exec rdnosql-telemetry-mongo mongosh /nosql/telemetry_schema.js
docker exec rdnosql-telemetry-mongo mongosh /nosql/telemetry_collector_tick.js
docker exec rdnosql-telemetry-mongo mongosh /nosql/telemetry_dashboard_queries.js
```
