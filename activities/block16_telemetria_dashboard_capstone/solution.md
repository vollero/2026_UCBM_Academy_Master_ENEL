# Soluzione - Blocco 16 - Dashboard e capstone NoSQL

La soluzione usa `nosql/telemetry_dashboard_queries.js`, che contiene le pipeline per costruire le card della dashboard.

## Comandi
```bash
docker compose -f docker-compose.telemetry.yml up -d
docker exec rdnosql-telemetry-mongo mongosh /nosql/telemetry_schema.js
docker exec rdnosql-telemetry-mongo mongosh /nosql/telemetry_dashboard_queries.js
```

## Card e granularità
| Card | Granularità |
| --- | --- |
| KPI generale | intero sistema |
| Ultima lettura | dispositivo |
| Trend | bucket temporale da 5 minuti |
| Energia | sito e tipo dispositivo |
| Ambiente | sito e regione |
| Alert | alert |
| Raw-curated | pipeline complessiva |

## Perché è corretta
- le card usano `readings_curated`, non il raw instabile;
- le pipeline sono versionate in un file `.js`;
- il controllo raw-curated verifica la pipeline;
- i valori nulli sono attesi quando metriche diverse appartengono a dispositivi diversi;
- il confronto con ticketing mostra la stessa architettura logica con DBMS diverso.
