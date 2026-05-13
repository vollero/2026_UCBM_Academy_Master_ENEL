# Architettura Telemetria Con MongoDB

Questa guida riguarda i blocchi 15-16. L'obiettivo è riprodurre una piccola architettura NoSQL per dati di telemetria con:

- un DBMS MongoDB;
- un collector simulato che genera letture periodiche;
- collezioni separate per dati raw, dati curati, anagrafica dispositivi e alert;
- query di aggregazione per costruire schede di dashboard;
- mongo-express per ispezionare database e documenti da browser.

Il modello ricalca lo schema architetturale visto nel sistema ticketing: una sorgente genera eventi, un DBMS li memorizza, alcune query trasformano i dati in indicatori leggibili.

## Avvio Dello Stack

Dalla cartella principale della repository:

```bash
docker compose -f docker-compose.telemetry.yml up -d
```

Controllare i container:

```bash
docker compose -f docker-compose.telemetry.yml ps
```

Seguire il collector simulato:

```bash
docker logs -f rdnosql-telemetry-collector
```

## Accesso A MongoDB

Entrare nella shell MongoDB:

```bash
docker exec -it rdnosql-telemetry-mongo mongosh
```

Dentro `mongosh`:

```javascript
use telemetry
show collections
db.devices.countDocuments()
db.readings_raw.countDocuments()
db.readings_curated.countDocuments()
db.alerts.countDocuments()
```

Guardare le ultime letture curate:

```javascript
db.readings_curated.find(
  {},
  { _id: 0, device_id: 1, ts: 1, metrics: 1, quality: 1 }
).sort({ ts: -1 }).limit(5)
```

## Accesso A mongo-express

Aprire:

```text
http://localhost:8081
```

Credenziali:

```text
user: training
password: training
```

mongo-express permette di esplorare database, collezioni e documenti. Non sostituisce `mongosh`, ma è utile per vedere la forma dei dati durante la lezione.

## Script Principali

Ricaricare schema, dati seed e indici:

```bash
docker exec rdnosql-telemetry-mongo mongosh /nosql/telemetry_schema.js
```

Simulare una nuova lettura:

```bash
docker exec rdnosql-telemetry-mongo mongosh /nosql/telemetry_collector_tick.js
```

Eseguire le query di dashboard:

```bash
docker exec rdnosql-telemetry-mongo mongosh /nosql/telemetry_dashboard_queries.js
```

Eseguire la soluzione del blocco 15:

```bash
docker exec rdnosql-telemetry-mongo mongosh /activities/block15_telemetria_mongodb_architettura/solution.js
```

Eseguire la soluzione del blocco 16:

```bash
docker exec rdnosql-telemetry-mongo mongosh /activities/block16_telemetria_dashboard_capstone/solution.js
```

## Collezioni Del Laboratorio

- `devices`: anagrafica dei dispositivi monitorati.
- `readings_raw`: letture ricevute dal collector, vicine alla forma originale dell'evento.
- `readings_curated`: letture ripulite e rese più comode per analisi e dashboard.
- `alerts`: eventi anomali o condizioni da segnalare.
- `collector_runs`: log delle esecuzioni del collector simulato.

La distinzione tra `readings_raw` e `readings_curated` serve a discutere una scelta architetturale frequente: conservare il dato originale e, in parallelo, preparare una vista più stabile per interrogazioni e report.

## Query Dashboard Da Costruire

Le query del laboratorio producono:

- conteggio dei dispositivi attivi;
- ultima lettura disponibile per dispositivo;
- andamento recente delle metriche;
- KPI energia;
- KPI ambientali;
- confronto tra dati raw e dati curati;
- elenco degli alert recenti.

Le aggregation pipeline sono nel file:

```text
nosql/telemetry_dashboard_queries.js
```

## Spegnimento E Reset

Fermare lo stack senza cancellare i dati:

```bash
docker compose -f docker-compose.telemetry.yml stop
```

Riavviare lo stack:

```bash
docker compose -f docker-compose.telemetry.yml up -d
```

Rimuovere container e volume dati:

```bash
docker compose -f docker-compose.telemetry.yml down -v
```

Ripartire da zero:

```bash
docker compose -f docker-compose.telemetry.yml down -v
docker compose -f docker-compose.telemetry.yml up -d
```
