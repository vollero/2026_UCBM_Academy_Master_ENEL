# Guida All'Uso Dell'Esempio Telemetry

Questa guida propone una sequenza di test da svolgere in aula per usare al meglio l'esempio di telemetria dei blocchi 15-16.

L'obiettivo non è solo "far partire MongoDB", ma mostrare alla classe un piccolo sistema dati:

- dispositivi che generano letture;
- dati raw conservati nella forma più vicina all'evento ricevuto;
- dati curati preparati per interrogazioni e dashboard;
- alert generati da condizioni anomale;
- query di aggregazione per trasformare documenti in indicatori.

I comandi vanno eseguiti dalla cartella principale della repository.

## Schema Mentale Da Presentare

```text
collector simulato
      |
      v
readings_raw  --->  readings_curated  --->  query dashboard
      |                    |
      |                    v
      +--------------->  alerts

devices = anagrafica dei dispositivi
collector_runs = log delle esecuzioni del collector
```

Punti da sottolineare:

- `readings_raw` conserva l'evento come arriva;
- `readings_curated` contiene la vista più comoda per dashboard e analisi;
- `devices` arricchisce ogni lettura con sito, regione e tipo dispositivo;
- `alerts` rende espliciti gli eventi critici;
- le aggregation pipeline sostituiscono, in questo laboratorio, le query SQL delle dashboard relazionali.

## Mappa Dettagliata Del Modello

Prima di eseguire i comandi, può essere utile mostrare alla classe il ruolo di ogni collection.

| Collection | Ruolo | Domande che abilita |
| --- | --- | --- |
| `devices` | anagrafica dei dispositivi | quali dispositivi esistono? dove sono? che tipo di metriche producono? |
| `readings_raw` | eventi ricevuti dal collector | che cosa è arrivato dal campo? quando è stato ricevuto? |
| `readings_curated` | vista pulita e arricchita | quali KPI posso calcolare? quali letture sono warning? |
| `alerts` | eventi anomali espliciti | quali condizioni richiedono attenzione? |
| `collector_runs` | log dell'ingestion | quante esecuzioni ha fatto il collector? con quale esito? |

Questa distinzione è centrale: il sistema non conserva solo "dati", conserva stati diversi dello stesso flusso.

## Granularità Dei Documenti

Nel laboratorio la granularità principale è:

```text
una lettura = un documento
```

Questa scelta rende naturale:

- ordinare le letture nel tempo;
- filtrare per dispositivo;
- calcolare trend;
- separare dispositivi energetici e ambientali;
- conservare metriche diverse nello stesso campo `metrics`.

La granularità alternativa "un dispositivo = un documento con tutte le letture dentro" sarebbe peggiore per questo caso: il documento crescerebbe senza limite e sarebbe più difficile interrogare finestre temporali.

## Modalità Consigliata Per La Lezione

Per una dimostrazione ordinata conviene partire in modalità controllata:

1. avviare solo MongoDB;
2. caricare schema e dati seed;
3. ispezionare le collection;
4. generare una lettura manuale;
5. confrontare conteggi raw/curated/alert;
6. eseguire le query dashboard;
7. solo alla fine avviare il collector continuo.

Avviare subito tutto lo stack è comodo, ma il collector automatico inserisce dati ogni 10 secondi. Durante una spiegazione può essere meglio fermarlo e produrre eventi uno alla volta.

## Test 0 - Reset Pulito

Usare questo test se si vuole partire da una situazione nota.

```bash
docker compose -f docker-compose.telemetry.yml down -v
docker compose -f docker-compose.telemetry.yml up -d mongo
docker compose -f docker-compose.telemetry.yml ps
```

Risultato atteso:

- il container `rdnosql-telemetry-mongo` è avviato;
- non sono ancora necessari `telemetry-collector` e `mongo-express`.

## Test 1 - Caricare Schema, Seed E Indici

```bash
docker exec rdnosql-telemetry-mongo mongosh /nosql/telemetry_schema.js
```

Risultato atteso:

```text
Telemetry database initialized
{
  devices: 5,
  raw: 16,
  curated: 16,
  alerts: 3
}
```

Messaggio didattico:

- ci sono 5 dispositivi;
- ci sono 16 letture iniziali raw;
- ci sono 16 letture curate;
- ci sono 3 alert iniziali;
- raw e curated partono allineati.

## Test 1A - Verificare Lo Stato Iniziale

```bash
docker exec rdnosql-telemetry-mongo mongosh --quiet --eval '
const t = db.getSiblingDB("telemetry");
printjson({
  collections: t.getCollectionNames().sort(),
  devices: t.devices.countDocuments(),
  raw: t.readings_raw.countDocuments(),
  curated: t.readings_curated.countDocuments(),
  alerts: t.alerts.countDocuments(),
  collector_runs: t.collector_runs.countDocuments()
});
'
```

Risultato atteso:

- sono presenti le collection principali;
- `raw` e `curated` hanno lo stesso numero di documenti;
- `collector_runs` contiene almeno il caricamento iniziale.

Domanda per la classe:

> Perché `collector_runs` è una collection separata e non un campo dentro `readings_raw`?

Risposta attesa:

> Perché descrive l'esecuzione del processo di ingestion, non la singola lettura. È un log operativo del collector.

## Test 1B - Guardare Il Vincolo Di Schema Su `devices`

La collection `devices` ha una validazione JSON Schema. Non è una validazione completa di tutto il sistema, ma mostra che anche in un database documentale si possono introdurre regole.

```bash
docker exec rdnosql-telemetry-mongo mongosh --quiet --eval '
const t = db.getSiblingDB("telemetry");
printjson(t.getCollectionInfos({ name: "devices" })[0].options.validator);
'
```

Messaggio didattico:

- NoSQL non significa assenza totale di schema;
- spesso lo schema è più flessibile e viene applicato in modo mirato;
- in questo laboratorio i dispositivi hanno campi obbligatori, mentre le metriche delle letture restano variabili.

Provare un inserimento volutamente errato:

```bash
docker exec rdnosql-telemetry-mongo mongosh --quiet --eval '
const t = db.getSiblingDB("telemetry");
try {
  t.devices.insertOne({ device_id: "BAD-001" });
  print("ERRORE: inserimento accettato, non dovrebbe succedere");
} catch (error) {
  print("ERRORE ATTESO");
  print(error.codeName || error.message);
}
'
```

Risultato atteso:

- l'inserimento fallisce;
- MongoDB segnala una violazione della validazione.

## Test 2 - Esplorare Le Collection

Entrare in `mongosh`:

```bash
docker exec -it rdnosql-telemetry-mongo mongosh
```

Dentro `mongosh`:

```javascript
use telemetry
show collections
db.devices.find({}, { _id: 0 }).sort({ device_id: 1 })
```

Domande per la classe:

- quali tipi di dispositivo sono presenti?
- quali dispositivi sono energetici?
- quali dispositivi sono ambientali?
- quali campi sembrano stabili?
- quali campi potrebbero cambiare tra dispositivi diversi?

Uscire:

```javascript
exit
```

## Test 3 - Confrontare Raw E Curated

Entrare in `mongosh`:

```bash
docker exec -it rdnosql-telemetry-mongo mongosh
```

Dentro `mongosh`:

```javascript
use telemetry

db.readings_raw.find(
  {},
  { _id: 0, raw_id: 1, received_at: 1, source: 1, payload: 1 }
).sort({ received_at: -1 }).limit(2)

db.readings_curated.find(
  {},
  { _id: 0, raw_id: 1, device_id: 1, device_type: 1, site: 1, region: 1, ts: 1, metrics: 1, status: 1, quality: 1 }
).sort({ ts: -1 }).limit(2)
```

Messaggio didattico:

- il documento raw conserva un `payload`;
- il documento curated porta fuori campi utili per query e dashboard;
- `device_type`, `site` e `region` arrivano dall'anagrafica `devices`;
- la duplicazione non è casuale: serve a rendere più semplici le letture.

Uscire:

```javascript
exit
```

## Test 3A - Seguire Uno Stesso Evento Da Raw A Curated

Questo test è utile perché mostra che raw e curated non sono due dataset indipendenti: sono due viste dello stesso flusso.

```bash
docker exec rdnosql-telemetry-mongo mongosh --quiet --eval '
const t = db.getSiblingDB("telemetry");
const raw = t.readings_raw.find({}, { _id: 0 }).sort({ received_at: -1 }).limit(1).toArray()[0];
print("RAW");
printjson(raw);
print("CURATED CORRISPONDENTE");
printjson(t.readings_curated.findOne({ raw_id: raw.raw_id }, { _id: 0 }));
'
```

Domande per la classe:

- quale campo collega raw e curated?
- quali campi sono stati copiati dal payload?
- quali campi sono stati aggiunti dall'anagrafica dispositivo?
- quale documento usereste per audit?
- quale documento usereste per una dashboard?

Messaggio didattico:

- `raw_id` è la chiave logica di collegamento;
- raw è più vicino all'ingestion;
- curated è più vicino all'uso analitico;
- la modellazione NoSQL deve dichiarare quale forma serve a quale lettura.

## Test 4 - Simulare Una Singola Lettura

Prima controllare i conteggi:

```bash
docker exec rdnosql-telemetry-mongo mongosh --quiet --eval '
const t = db.getSiblingDB("telemetry");
printjson({
  raw: t.readings_raw.countDocuments(),
  curated: t.readings_curated.countDocuments(),
  alerts: t.alerts.countDocuments(),
  collector_runs: t.collector_runs.countDocuments()
});
'
```

Generare una lettura:

```bash
docker exec rdnosql-telemetry-mongo mongosh /nosql/telemetry_collector_tick.js
```

Ricontrollare i conteggi:

```bash
docker exec rdnosql-telemetry-mongo mongosh --quiet --eval '
const t = db.getSiblingDB("telemetry");
printjson({
  raw: t.readings_raw.countDocuments(),
  curated: t.readings_curated.countDocuments(),
  alerts: t.alerts.countDocuments(),
  collector_runs: t.collector_runs.countDocuments()
});
'
```

Risultato atteso:

- `raw` aumenta di 1;
- `curated` aumenta di 1;
- `collector_runs` aumenta di 1;
- `alerts` aumenta solo se la lettura generata è in warning.

Messaggio didattico:

- un singolo evento produce più effetti;
- non tutte le letture producono alert;
- il collector è una simulazione di ingestion.

## Test 5 - Osservare L'Ultima Lettura

```bash
docker exec rdnosql-telemetry-mongo mongosh --quiet --eval '
const t = db.getSiblingDB("telemetry");
printjson(t.readings_curated.find(
  {},
  { _id: 0, raw_id: 1, device_id: 1, device_type: 1, site: 1, region: 1, ts: 1, status: 1, metrics: 1 }
).sort({ ts: -1 }).limit(1).toArray());
'
```

Domande per la classe:

- quale dispositivo ha generato l'ultima lettura?
- quali metriche contiene?
- perché le metriche cambiano a seconda del tipo dispositivo?
- quale campo useremmo per filtrare per area geografica?
- quale campo useremmo per filtrare warning?

## Test 5A - Forzare Una Lettura Warning Deterministica

Il collector genera dati casuali. Per spiegare bene gli alert può essere utile creare una lettura deterministica che produce sicuramente un warning.

```bash
docker exec rdnosql-telemetry-mongo mongosh --quiet --eval '
const t = db.getSiblingDB("telemetry");
const device = t.devices.findOne({ device_id: "TR-roma-001" });
const now = new Date();
const rawId = "class-warning-" + now.getTime();

const rawDoc = {
  raw_id: rawId,
  received_at: now,
  source: "class_demo",
  payload: {
    device_id: device.device_id,
    ts: now,
    metrics: {
      temperature_c: 82.5,
      load_kw: 980.0,
      voltage_v: 19820
    },
    status: "warning",
    firmware: "class-demo"
  }
};

t.readings_raw.insertOne(rawDoc);
t.readings_curated.insertOne({
  raw_id: rawId,
  device_id: device.device_id,
  device_type: device.device_type,
  site: device.site,
  region: device.region,
  ts: now,
  metrics: rawDoc.payload.metrics,
  status: "warning",
  quality: { valid: true, reason: "class_demo_forced_warning" },
  ingestion: { source: rawDoc.source, received_at: rawDoc.received_at }
});
t.alerts.insertOne({
  alert_id: "AL-" + rawId,
  device_id: device.device_id,
  ts: now,
  severity: "warning",
  rule: "transformer_temperature_high",
  message: "Class demo: transformer temperature above threshold"
});
t.collector_runs.insertOne({
  run_id: rawId,
  started_at: now,
  completed_at: new Date(),
  inserted_raw: 1,
  inserted_curated: 1,
  inserted_alerts: 1,
  status: "completed"
});

printjson({ inserted: rawId, device_id: device.device_id, status: "warning" });
'
```

Verificare l'alert:

```bash
docker exec rdnosql-telemetry-mongo mongosh --quiet --eval '
const t = db.getSiblingDB("telemetry");
printjson(t.alerts.find(
  { rule: "transformer_temperature_high" },
  { _id: 0, alert_id: 1, device_id: 1, ts: 1, rule: 1, message: 1 }
).sort({ ts: -1 }).limit(3).toArray());
'
```

Messaggio didattico:

- un alert è una vista esplicita di una condizione anomala;
- l'evento raw resta disponibile;
- la lettura curated alimenta le query;
- l'alert alimenta un flusso operativo diverso.

## Test 6 - Eseguire Le Query Dashboard

```bash
docker exec rdnosql-telemetry-mongo mongosh /nosql/telemetry_dashboard_queries.js
```

Le sezioni prodotte sono:

| Numero | Card | Concetto |
| --- | --- | --- |
| 1 | KPI sintesi telemetria | conteggi e warning |
| 2 | Ultima lettura per dispositivo | ordinamento e raggruppamento |
| 3 | Trend per intervallo di 5 minuti | bucket temporali |
| 4 | Metriche energia per sito | filtro per tipo dispositivo |
| 5 | Monitoraggio ambientale | metriche variabili |
| 6 | Controllo raw-curated | qualità del flusso |
| 7 | Alert recenti | ordinamento e limit |

Messaggio didattico:

- una dashboard è un insieme di domande, non solo grafici;
- ogni card ha una granularità;
- le aggregation pipeline costruiscono viste derivate;
- la collection `readings_curated` è più adatta alle dashboard della collection raw.

## Test 6A - Costruire Una Card Passo-Passo

Obiettivo: ultima lettura per dispositivo.

Prima mostrare le letture ordinate:

```bash
docker exec rdnosql-telemetry-mongo mongosh --quiet --eval '
const t = db.getSiblingDB("telemetry");
printjson(t.readings_curated.find(
  {},
  { _id: 0, device_id: 1, ts: 1, status: 1 }
).sort({ device_id: 1, ts: -1 }).limit(10).toArray());
'
```

Poi mostrare la pipeline:

```bash
docker exec rdnosql-telemetry-mongo mongosh --quiet --eval '
const t = db.getSiblingDB("telemetry");
printjson(t.readings_curated.aggregate([
  { $sort: { device_id: 1, ts: -1 } },
  {
    $group: {
      _id: "$device_id",
      last_ts: { $first: "$ts" },
      last_status: { $first: "$status" },
      last_metrics: { $first: "$metrics" }
    }
  },
  { $sort: { _id: 1 } }
]).toArray());
'
```

Spiegazione:

- `$sort` mette prima la lettura più recente per ogni dispositivo;
- `$group` crea un gruppo per dispositivo;
- `$first` prende il primo documento nel gruppo, quindi l'ultimo nel tempo;
- il risultato è una card "stato corrente".

Domanda per la classe:

> Che cosa succede se dimentichiamo il `$sort` prima del `$group`?

Risposta attesa:

> `$first` non rappresenta più necessariamente la lettura più recente. L'aggregazione diventa semanticamente sbagliata anche se non produce errore.

## Test 6B - Nuova Card: Warning Per Regione

Questa card non è nello script base, ma è utile per far costruire una query partendo da una domanda.

Domanda:

> Quanti warning abbiamo per regione?

Pipeline:

```bash
docker exec rdnosql-telemetry-mongo mongosh --quiet --eval '
const t = db.getSiblingDB("telemetry");
printjson(t.readings_curated.aggregate([
  { $match: { status: "warning" } },
  {
    $group: {
      _id: "$region",
      warnings: { $sum: 1 },
      devices: { $addToSet: "$device_id" }
    }
  },
  {
    $project: {
      _id: 0,
      region: "$_id",
      warnings: 1,
      affected_devices: { $size: "$devices" }
    }
  },
  { $sort: { warnings: -1, region: 1 } }
]).toArray());
'
```

Messaggio didattico:

- il `$match` riduce la popolazione;
- il `$group` definisce la granularità della card;
- `$addToSet` evita di contare lo stesso dispositivo più volte;
- `$project` prepara un output leggibile per dashboard.

## Test 6C - Nuova Card: Qualità Ingestion Per Sorgente

Domanda:

> Da quali sorgenti arrivano le letture curate?

Pipeline:

```bash
docker exec rdnosql-telemetry-mongo mongosh --quiet --eval '
const t = db.getSiblingDB("telemetry");
printjson(t.readings_curated.aggregate([
  {
    $group: {
      _id: "$ingestion.source",
      readings: { $sum: 1 },
      first_seen: { $min: "$ingestion.received_at" },
      last_seen: { $max: "$ingestion.received_at" }
    }
  },
  {
    $project: {
      _id: 0,
      source: "$_id",
      readings: 1,
      first_seen: 1,
      last_seen: 1
    }
  },
  { $sort: { readings: -1 } }
]).toArray());
'
```

Messaggio didattico:

- non tutte le dashboard sono metriche di business;
- alcune dashboard servono a controllare la pipeline;
- `ingestion.source` permette di distinguere seed, collector simulato e demo in aula.

## Test 7 - Controllare Raw-Curated

Eseguire il controllo di allineamento:

```bash
docker exec rdnosql-telemetry-mongo mongosh --quiet --eval '
const t = db.getSiblingDB("telemetry");
printjson({
  raw_events: t.readings_raw.countDocuments(),
  curated_readings: t.readings_curated.countDocuments(),
  raw_without_curated: t.readings_raw.aggregate([
    {
      $lookup: {
        from: "readings_curated",
        localField: "raw_id",
        foreignField: "raw_id",
        as: "curated"
      }
    },
    { $match: { curated: { $size: 0 } } },
    { $count: "missing" }
  ]).toArray()
});
'
```

Risultato atteso:

- `raw_events` e `curated_readings` dovrebbero essere uguali;
- `raw_without_curated` dovrebbe essere vuoto.

Messaggio didattico:

- il dato raw permette di controllare la pipeline;
- il dato curated permette di interrogare meglio;
- nei sistemi reali questo controllo diventa una metrica di qualità.

## Test 7A - Creare Un Errore Raw-Curated E Ripararlo

Questo test rende concreto il concetto di controllo qualità. Inseriamo volutamente un raw senza curated.

Creare il disallineamento:

```bash
docker exec rdnosql-telemetry-mongo mongosh --quiet --eval '
const t = db.getSiblingDB("telemetry");
const rawId = "class-raw-only";
t.readings_raw.deleteOne({ raw_id: rawId });
t.readings_curated.deleteOne({ raw_id: rawId });
t.readings_raw.insertOne({
  raw_id: rawId,
  received_at: new Date(),
  source: "class_demo_broken_pipeline",
  payload: {
    device_id: "ENV-torino-004",
    ts: new Date(),
    metrics: { temperature_c: 22.5, humidity_pct: 58, pm25_ugm3: 41 },
    status: "warning",
    firmware: "class-demo"
  }
});
print("Inserito raw senza curated: " + rawId);
'
```

Eseguire il controllo:

```bash
docker exec rdnosql-telemetry-mongo mongosh --quiet --eval '
const t = db.getSiblingDB("telemetry");
printjson(t.readings_raw.aggregate([
  {
    $lookup: {
      from: "readings_curated",
      localField: "raw_id",
      foreignField: "raw_id",
      as: "curated"
    }
  },
  { $match: { curated: { $size: 0 } } },
  { $project: { _id: 0, raw_id: 1, source: 1, payload: 1 } }
]).toArray());
'
```

Riparare il disallineamento creando il curated corrispondente:

```bash
docker exec rdnosql-telemetry-mongo mongosh --quiet --eval '
const t = db.getSiblingDB("telemetry");
const raw = t.readings_raw.findOne({ raw_id: "class-raw-only" });
const device = t.devices.findOne({ device_id: raw.payload.device_id });
t.readings_curated.insertOne({
  raw_id: raw.raw_id,
  device_id: raw.payload.device_id,
  device_type: device.device_type,
  site: device.site,
  region: device.region,
  ts: raw.payload.ts,
  metrics: raw.payload.metrics,
  status: raw.payload.status,
  quality: { valid: true, reason: "manual_repair_in_class" },
  ingestion: { source: raw.source, received_at: raw.received_at }
});
print("Curated ricostruito per " + raw.raw_id);
'
```

Rieseguire il controllo raw-curated. Il documento `class-raw-only` non deve più comparire tra i mancanti.

Messaggio didattico:

- il raw permette di ricostruire una vista curated persa;
- un sistema robusto deve prevedere backfill e riparazione;
- la qualità dei dati non è solo una query, è una proprietà architetturale.

## Test 8 - Mostrare Gli Indici

```bash
docker exec rdnosql-telemetry-mongo mongosh --quiet --eval '
const t = db.getSiblingDB("telemetry");
print("devices");
printjson(t.devices.getIndexes());
print("readings_curated");
printjson(t.readings_curated.getIndexes());
print("alerts");
printjson(t.alerts.getIndexes());
'
```

Messaggio didattico:

- gli indici seguono le query principali;
- `device_id + ts` serve per cercare le ultime letture di un dispositivo;
- `device_type + ts` serve per separare energia e ambiente;
- `region + ts` serve per dashboard territoriali;
- `severity + ts` serve per alert recenti.

## Test 8A - Usare `explain` Su Una Query Indicizzata

Obiettivo: mostrare che un indice non è un concetto astratto. Cambia il piano di esecuzione.

```bash
docker exec rdnosql-telemetry-mongo mongosh --quiet --eval '
const t = db.getSiblingDB("telemetry");
const plan = t.readings_curated
  .find({ device_id: "TR-roma-001" })
  .sort({ ts: -1 })
  .limit(5)
  .explain("executionStats");

printjson({
  totalKeysExamined: plan.executionStats.totalKeysExamined,
  totalDocsExamined: plan.executionStats.totalDocsExamined,
  executionTimeMillis: plan.executionStats.executionTimeMillis,
  winningPlan: plan.queryPlanner.winningPlan
});
'
```

Che cosa osservare:

- presenza di un piano che usa l'indice su `device_id` e `ts`;
- numero di chiavi esaminate;
- numero di documenti esaminati;
- differenza tra "la query funziona" e "la query è sostenibile".

## Test 8B - Query Non Ottimizzata Su Campo Dentro `metrics`

Eseguire una query su una metrica annidata non indicizzata:

```bash
docker exec rdnosql-telemetry-mongo mongosh --quiet --eval '
const t = db.getSiblingDB("telemetry");
const plan = t.readings_curated
  .find({ "metrics.temperature_c": { $gte: 70 } })
  .explain("executionStats");

printjson({
  totalKeysExamined: plan.executionStats.totalKeysExamined,
  totalDocsExamined: plan.executionStats.totalDocsExamined,
  executionTimeMillis: plan.executionStats.executionTimeMillis,
  winningPlan: plan.queryPlanner.winningPlan
});
'
```

Discussione:

- la query è espressiva, ma potrebbe non essere ottimizzata;
- indicizzare ogni metrica possibile non è gratis;
- le metriche variabili rendono più importante progettare le query principali;
- questo è lo stesso ragionamento visto con gli indici SQL: letture più veloci, scritture e storage più costosi.

## Test 8C - Esperimento Temporaneo Con Un Nuovo Indice

Creare un indice temporaneo sulla temperatura:

```bash
docker exec rdnosql-telemetry-mongo mongosh --quiet --eval '
const t = db.getSiblingDB("telemetry");
t.readings_curated.createIndex({ "metrics.temperature_c": 1 });
const plan = t.readings_curated
  .find({ "metrics.temperature_c": { $gte: 70 } })
  .explain("executionStats");
printjson({
  totalKeysExamined: plan.executionStats.totalKeysExamined,
  totalDocsExamined: plan.executionStats.totalDocsExamined,
  executionTimeMillis: plan.executionStats.executionTimeMillis,
  winningPlan: plan.queryPlanner.winningPlan
});
t.readings_curated.dropIndex("metrics.temperature_c_1");
'
```

Messaggio didattico:

- l'indice può migliorare una query specifica;
- l'indice occupa spazio e rallenta ogni scrittura che aggiorna quel campo;
- in telemetria bisogna scegliere gli indici in base alle dashboard e agli alert realmente necessari.

## Test 9 - Usare mongo-express

Avviare l'interfaccia:

```bash
docker compose -f docker-compose.telemetry.yml up -d mongo-express
```

Aprire:

```text
http://localhost:8081
```

Credenziali:

```text
user: training
password: training
```

Azioni consigliate:

1. aprire il database `telemetry`;
2. aprire la collection `devices`;
3. mostrare un documento dispositivo;
4. aprire `readings_raw`;
5. mostrare il campo `payload`;
6. aprire `readings_curated`;
7. mostrare i campi arricchiti `site`, `region`, `device_type`;
8. aprire `alerts` e discutere quali condizioni generano warning.

Messaggio didattico:

- mongo-express aiuta a vedere la forma dei documenti;
- per query e aggregazioni resta più controllabile usare `mongosh`.

## Test 10 - Avviare Il Collector Continuo

Quando la classe ha capito la singola lettura, avviare il collector automatico:

```bash
docker compose -f docker-compose.telemetry.yml up -d telemetry-collector
docker logs -f rdnosql-telemetry-collector
```

In un altro terminale, osservare i conteggi:

```bash
docker exec rdnosql-telemetry-mongo mongosh --quiet --eval '
const t = db.getSiblingDB("telemetry");
printjson({
  raw: t.readings_raw.countDocuments(),
  curated: t.readings_curated.countDocuments(),
  alerts: t.alerts.countDocuments(),
  collector_runs: t.collector_runs.countDocuments()
});
'
```

Fermare solo il collector:

```bash
docker compose -f docker-compose.telemetry.yml stop telemetry-collector
```

Messaggio didattico:

- il sistema produce dati nel tempo;
- i dati cambiano mentre le query restano le stesse;
- una dashboard reale deve gestire aggiornamento continuo e finestre temporali.

## Test 10A - Guardare La Crescita Nel Tempo

Lasciare il collector attivo per 30-60 secondi, poi eseguire:

```bash
docker exec rdnosql-telemetry-mongo mongosh --quiet --eval '
const t = db.getSiblingDB("telemetry");
printjson(t.collector_runs.aggregate([
  {
    $group: {
      _id: "$status",
      runs: { $sum: 1 },
      raw_inserted: { $sum: "$inserted_raw" },
      curated_inserted: { $sum: "$inserted_curated" },
      alerts_inserted: { $sum: "$inserted_alerts" }
    }
  }
]).toArray());
'
```

Messaggio didattico:

- il collector ha una sua osservabilità;
- un sistema dati reale deve monitorare non solo i dati prodotti, ma anche i processi che li producono;
- `collector_runs` è il punto di partenza per metriche di ingestion.

## Test 11 - Discutere Metriche Variabili

Eseguire:

```bash
docker exec rdnosql-telemetry-mongo mongosh --quiet --eval '
const t = db.getSiblingDB("telemetry");
print("Transformer");
printjson(t.readings_curated.find(
  { device_type: "transformer" },
  { _id: 0, device_id: 1, metrics: 1 }
).limit(1).toArray());
print("Air quality");
printjson(t.readings_curated.find(
  { device_type: "air_quality_station" },
  { _id: 0, device_id: 1, metrics: 1 }
).limit(1).toArray());
'
```

Domande per la classe:

- perché un documento transformer non ha `pm25_ugm3`?
- perché una stazione ambientale non ha `load_kw`?
- come modelleremmo questa variabilità in tabelle relazionali?
- quali vantaggi dà il documento?
- quali controlli perdiamo se lo schema è troppo libero?

## Test 12 - Aggiungere Un Nuovo Tipo Di Dispositivo

Questo test mostra perché il modello documentale è comodo quando arrivano dispositivi con metriche nuove.

Inserire un sensore di rumore:

```bash
docker exec rdnosql-telemetry-mongo mongosh --quiet --eval '
const t = db.getSiblingDB("telemetry");
t.devices.updateOne(
  { device_id: "NOISE-napoli-006" },
  {
    $setOnInsert: {
      device_id: "NOISE-napoli-006",
      device_type: "noise_sensor",
      site: "Napoli Centro",
      region: "south",
      active: true,
      sampling_seconds: 60,
      tags: ["environment", "noise"]
    }
  },
  { upsert: true }
);

const device = t.devices.findOne({ device_id: "NOISE-napoli-006" });
const now = new Date();
const rawId = "class-noise-" + now.getTime();
const metrics = {
  noise_db: 68.4,
  peak_db: 81.2,
  traffic_index: 0.74
};

t.readings_raw.insertOne({
  raw_id: rawId,
  received_at: now,
  source: "class_demo_new_device",
  payload: {
    device_id: device.device_id,
    ts: now,
    metrics,
    status: "ok",
    firmware: "class-demo"
  }
});

t.readings_curated.insertOne({
  raw_id: rawId,
  device_id: device.device_id,
  device_type: device.device_type,
  site: device.site,
  region: device.region,
  ts: now,
  metrics,
  status: "ok",
  quality: { valid: true, reason: "class_demo_new_device_type" },
  ingestion: { source: "class_demo_new_device", received_at: now }
});

printjson(t.readings_curated.findOne({ raw_id: rawId }, { _id: 0 }));
'
```

Discussione:

- non abbiamo modificato una tabella per aggiungere `noise_db`;
- la metrica nuova entra nel documento `metrics`;
- la dashboard esistente non sa ancora come interpretarla;
- flessibilità dello schema non significa dashboard automatiche;
- serve comunque progettare query, indici e controlli per il nuovo caso.

## Test 13 - Nuova Card Per Il Nuovo Dispositivo

Domanda:

> Qual è il rumore medio registrato dai sensori di rumore?

Pipeline:

```bash
docker exec rdnosql-telemetry-mongo mongosh --quiet --eval '
const t = db.getSiblingDB("telemetry");
printjson(t.readings_curated.aggregate([
  { $match: { device_type: "noise_sensor" } },
  {
    $group: {
      _id: { site: "$site", region: "$region" },
      readings: { $sum: 1 },
      avg_noise_db: { $avg: "$metrics.noise_db" },
      max_peak_db: { $max: "$metrics.peak_db" }
    }
  },
  {
    $project: {
      _id: 0,
      site: "$_id.site",
      region: "$_id.region",
      readings: 1,
      avg_noise_db: 1,
      max_peak_db: 1
    }
  }
]).toArray());
'
```

Messaggio didattico:

- il modello documentale ha assorbito una nuova forma di dato;
- la query deve conoscere la semantica della nuova metrica;
- lo schema fisico può essere flessibile, ma il significato resta una responsabilità del progetto.

## Test 14 - Confrontare Modellazione Relazionale E Documentale

Usare la classe per confrontare due possibili rappresentazioni.

Rappresentazione documentale:

```javascript
{
  device_id: "NOISE-napoli-006",
  device_type: "noise_sensor",
  ts: ISODate("2026-05-15T10:00:00Z"),
  metrics: {
    noise_db: 68.4,
    peak_db: 81.2,
    traffic_index: 0.74
  }
}
```

Possibile rappresentazione relazionale generica:

```text
reading(id, device_id, ts, status)
reading_metric(reading_id, metric_name, metric_value)
```

Discussione:

| Aspetto | Documento | Relazionale generico |
| --- | --- | --- |
| Inserire metriche nuove | semplice | semplice |
| Vincolare tipi e unità | più applicativo | richiede tabelle di dominio |
| Query su una metrica specifica | comoda se nota | richiede filtri per nome metrica |
| Aggregazioni cross-metrica | pipeline su campi annidati | join e pivot |
| Controlli forti | da progettare | più naturali con vincoli |

Messaggio didattico:

- nessun modello è gratis;
- il documento è naturale per payload variabili;
- il relazionale è forte quando servono vincoli e consistenza strutturale;
- la scelta dipende dalle domande e dai costi accettati.

## Test 15 - Far Ragionare Sui Trade-Off

Usare questa tabella come discussione finale.

| Scelta | Vantaggio | Trade-off |
| --- | --- | --- |
| Conservare raw e curated | audit e dashboard più semplici | più storage e sincronizzazione da controllare |
| Usare documenti con metriche variabili | naturale per dispositivi diversi | validazione meno rigida |
| Avviare collector continuo | mostra dati che cambiano nel tempo | demo meno deterministica |
| Usare indici multipli | query più veloci | scritture più costose |
| Usare MongoDB per telemetria | comodo per documenti JSON | per carichi time-series molto grandi si valutano motori specializzati |
| Aggiungere metriche nuove senza migrazione tabellare | evoluzione rapida | dashboard e validazioni devono essere aggiornate |
| Separare alert da letture | workflow operativo più chiaro | duplicazione e coerenza da gestire |

Domanda conclusiva:

> Questo sistema è un sostituto del relazionale o un esempio di persistenza specializzata per un access pattern specifico?

Risposta attesa:

> È un esempio di persistenza specializzata. Il relazionale resta adatto a dati core, vincoli e transazioni; MongoDB è utile qui per documenti di telemetria, metriche variabili e pipeline di aggregazione.

## Sequenza Breve Da 15 Minuti

Usare questa sequenza se resta poco tempo:

```bash
docker compose -f docker-compose.telemetry.yml down -v
docker compose -f docker-compose.telemetry.yml up -d mongo
docker exec rdnosql-telemetry-mongo mongosh /nosql/telemetry_schema.js
docker exec rdnosql-telemetry-mongo mongosh /nosql/telemetry_collector_tick.js
docker exec rdnosql-telemetry-mongo mongosh /nosql/telemetry_dashboard_queries.js
```

Poi aprire `mongo-express`:

```bash
docker compose -f docker-compose.telemetry.yml up -d mongo-express
```

## Sequenza Completa Da 45-60 Minuti

1. Reset pulito.
2. Avvio solo MongoDB.
3. Caricamento schema.
4. Ispezione `devices`.
5. Confronto `readings_raw` / `readings_curated`.
6. Collector manuale.
7. Conteggi prima/dopo.
8. Query dashboard.
9. Controllo raw-curated.
10. Indici.
11. mongo-express.
12. Collector continuo.
13. Discussione trade-off.

## Sequenza Estesa Da 90 Minuti

1. Reset pulito e schema.
2. Lettura del modello e delle collection.
3. Validazione JSON Schema su `devices`.
4. Raw e curated sullo stesso `raw_id`.
5. Collector manuale.
6. Lettura warning deterministica.
7. Pipeline dashboard base.
8. Pipeline costruita passo-passo.
9. Nuove card: warning per regione e qualità ingestion.
10. Errore raw-curated e riparazione.
11. Indici ed `explain`.
12. Indice temporaneo su metrica annidata.
13. mongo-express.
14. Collector continuo e crescita nel tempo.
15. Nuovo tipo dispositivo `noise_sensor`.
16. Nuova card sul rumore.
17. Confronto relazionale/documentale.
18. Discussione finale sui trade-off.

## Stop E Pulizia

Fermare conservando i dati:

```bash
docker compose -f docker-compose.telemetry.yml stop
```

Rimuovere i container conservando i volumi:

```bash
docker compose -f docker-compose.telemetry.yml down
```

Ripartire da zero cancellando i dati:

```bash
docker compose -f docker-compose.telemetry.yml down -v
```

## Problemi Comuni

| Problema | Controllo | Soluzione |
| --- | --- | --- |
| conflitto `container name "/rdnosql-telemetry-mongo" is already in use` | `docker ps -a --filter name=rdnosql-telemetry` | eseguire `docker compose -f docker-compose.telemetry.yml down` dalla repository che ha creato i container, poi rilanciare `up -d` |
| `mongo-express` non risponde | `docker compose -f docker-compose.telemetry.yml ps` | avviare `mongo-express` |
| i conteggi cambiano mentre si spiega | `docker compose -f docker-compose.telemetry.yml ps` | fermare `telemetry-collector` |
| collection vuote | conteggi su `telemetry` | rieseguire `telemetry_schema.js` |
| porta 8081 occupata | `docker ps` | fermare il container che usa la porta o cambiare porta nel compose |
| porta 27018 occupata | `docker ps` | fermare il container che usa la porta o cambiare porta nel compose |
| output diverso tra studenti | collector continuo attivo | usare reset e avvio controllato |

### Caso Specifico: Nome Container Già In Uso

Il file `docker-compose.telemetry.yml` usa nomi container espliciti:

```text
rdnosql-telemetry-mongo
rdnosql-telemetry-collector
rdnosql-telemetry-mongo-express
```

Questo rende i comandi più semplici da copiare in aula, ma significa che non possono esistere due stack telemetry avviati da cartelle diverse nello stesso computer.

Se compare l'errore:

```text
Conflict. The container name "/rdnosql-telemetry-mongo" is already in use
```

controllare i container esistenti:

```bash
docker ps -a --filter name=rdnosql-telemetry
```

Soluzione senza cancellare i dati del volume:

```bash
docker compose -f docker-compose.telemetry.yml down
docker compose -f docker-compose.telemetry.yml up -d
```

Se il container è stato creato da un'altra cartella e `down` non lo rimuove, rimuovere solo i container, non i volumi:

```bash
docker rm rdnosql-telemetry-collector rdnosql-telemetry-mongo-express rdnosql-telemetry-mongo
docker compose -f docker-compose.telemetry.yml up -d
```

Usare `down -v` solo quando si vuole cancellare anche il database MongoDB e ripartire da zero.

## Checklist Finale Per La Classe

Alla fine della demo gli studenti dovrebbero saper spiegare:

- quali collection compongono il database `telemetry`;
- perché esistono sia raw sia curated;
- come il collector modifica il database;
- come si legge un documento MongoDB;
- come una aggregation pipeline diventa una card di dashboard;
- quali indici supportano le query principali;
- come usare `explain` per discutere il costo di una query;
- come riconoscere e riparare un disallineamento raw-curated;
- perché l'aggiunta di un nuovo tipo dispositivo è semplice ma non gratuita;
- quali trade-off introduce una soluzione NoSQL rispetto a una relazionale.
