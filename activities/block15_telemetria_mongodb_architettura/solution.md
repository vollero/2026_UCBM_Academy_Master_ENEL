# Soluzione - Blocco 15 - Telemetria NoSQL con MongoDB

La soluzione avvia lo stack, inizializza MongoDB e verifica che collector, raw, curated e alert funzionino.

## Comandi
```bash
docker compose -f docker-compose.telemetry.yml up -d
docker exec rdnosql-telemetry-mongo mongosh /nosql/telemetry_schema.js
docker exec rdnosql-telemetry-mongo mongosh /nosql/telemetry_collector_tick.js
docker exec rdnosql-telemetry-mongo mongosh /nosql/telemetry_collector_tick.js
docker exec rdnosql-telemetry-mongo mongosh /nosql/telemetry_dashboard_queries.js
```

## Controllo in mongosh
```javascript
const t = db.getSiblingDB("telemetry");

printjson({
  devices: t.devices.countDocuments(),
  raw: t.readings_raw.countDocuments(),
  curated: t.readings_curated.countDocuments(),
  alerts: t.alerts.countDocuments()
});

printjson(t.readings_curated.find({}, { _id: 0 }).sort({ ts: -1 }).limit(3).toArray());
printjson(t.readings_curated.getIndexes());
```

## Perché è corretta
- lo stack è replicabile con Docker Compose;
- il DBMS è MongoDB, quindi i dati sono documenti;
- raw conserva il messaggio ricevuto;
- curated contiene dati arricchiti per query e dashboard;
- il collector simula nuove letture e possibili alert;
- gli indici seguono dispositivo, tempo, tipo e regione.
