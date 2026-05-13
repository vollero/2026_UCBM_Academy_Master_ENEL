# Blocco 15 - Telemetria NoSQL con MongoDB

## 1. Problema in forma informale
Bisogna avviare un sistema di telemetria containerizzato: MongoDB come DBMS documentale, collector simulato, dati raw, dati curati e interfaccia web per ispezione.

## 2. Specifica corretta del problema
- input: `docker-compose.telemetry.yml` e script `nosql/*.js`;
- output: stack avviato, database `telemetry` popolato, collector funzionante;
- vincolo: distinguere `readings_raw` e `readings_curated`;
- vincolo: dimostrare che il collector aggiunge letture;
- vincolo: spiegare almeno un documento curato e un indice.

## 3. Definizione della soluzione
1. avviare lo stack;
2. caricare o rigenerare lo schema;
3. controllare collection e conteggi;
4. eseguire manualmente il collector;
5. verificare raw, curated e alert;
6. leggere gli indici.

## 4. Implementazione completa
```bash
docker compose -f docker-compose.telemetry.yml up -d
docker compose -f docker-compose.telemetry.yml ps
docker logs -f rdnosql-telemetry-collector
```

```bash
docker exec rdnosql-telemetry-mongo mongosh /nosql/telemetry_schema.js
docker exec rdnosql-telemetry-mongo mongosh /nosql/telemetry_collector_tick.js
docker exec rdnosql-telemetry-mongo mongosh /nosql/telemetry_collector_tick.js
```

```bash
docker exec rdnosql-telemetry-mongo mongosh /nosql/telemetry_dashboard_queries.js
```

## 5. Query di controllo
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

## 6. Criteri di verifica
- i container sono avviati;
- mongo-express è raggiungibile su `http://localhost:8081`;
- il database `telemetry` contiene le collection previste;
- il collector aumenta i conteggi;
- raw e curated restano allineati;
- gli indici sono coerenti con le query.
