# Soluzione - Blocco 14 - Scenari e modellazione NoSQL

## Collection
- `devices`: anagrafica dispositivo, tipo, sito, regione, tag e stato operativo.
- `readings_raw`: messaggio ricevuto dal collector, quasi nella forma originale.
- `readings_curated`: lettura arricchita con metadati utili alla dashboard.
- `alerts`: eventi generati da regole di soglia.

## Documento raw
```javascript
{
  raw_id: "seed-3",
  received_at: ISODate("2026-05-13T08:10:02Z"),
  source: "seed_loader",
  payload: {
    device_id: "TR-roma-001",
    ts: ISODate("2026-05-13T08:10:00Z"),
    metrics: {
      temperature_c: 71.4,
      load_kw: 910,
      voltage_v: 19950
    },
    status: "warning"
  }
}
```

## Documento curated
```javascript
{
  raw_id: "seed-3",
  device_id: "TR-roma-001",
  device_type: "transformer",
  site: "Roma Nord",
  region: "center",
  ts: ISODate("2026-05-13T08:10:00Z"),
  metrics: {
    temperature_c: 71.4,
    load_kw: 910,
    voltage_v: 19950
  },
  status: "warning",
  quality: {
    valid: true,
    reason: "seeded"
  }
}
```

## Indici
```javascript
db.readings_curated.createIndex({ device_id: 1, ts: -1 });
db.readings_curated.createIndex({ device_type: 1, ts: -1 });
db.readings_curated.createIndex({ region: 1, ts: -1 });
db.alerts.createIndex({ severity: 1, ts: -1 });
```

## Perché è corretta
- `readings_raw` conserva il messaggio originale;
- `readings_curated` rende più semplice la dashboard;
- `site` e `region` sono duplicati consapevolmente come snapshot;
- le metriche variabili restano in `metrics`;
- gli indici seguono le query principali.
