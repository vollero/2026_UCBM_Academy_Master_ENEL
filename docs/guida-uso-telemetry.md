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

## Test 12 - Far Ragionare Sui Trade-Off

Usare questa tabella come discussione finale.

| Scelta | Vantaggio | Trade-off |
| --- | --- | --- |
| Conservare raw e curated | audit e dashboard più semplici | più storage e sincronizzazione da controllare |
| Usare documenti con metriche variabili | naturale per dispositivi diversi | validazione meno rigida |
| Avviare collector continuo | mostra dati che cambiano nel tempo | demo meno deterministica |
| Usare indici multipli | query più veloci | scritture più costose |
| Usare MongoDB per telemetria | comodo per documenti JSON | per carichi time-series molto grandi si valutano motori specializzati |

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
| `mongo-express` non risponde | `docker compose -f docker-compose.telemetry.yml ps` | avviare `mongo-express` |
| i conteggi cambiano mentre si spiega | `docker compose -f docker-compose.telemetry.yml ps` | fermare `telemetry-collector` |
| collection vuote | conteggi su `telemetry` | rieseguire `telemetry_schema.js` |
| porta 8081 occupata | `docker ps` | fermare il container che usa la porta o cambiare porta nel compose |
| porta 27018 occupata | `docker ps` | fermare il container che usa la porta o cambiare porta nel compose |
| output diverso tra studenti | collector continuo attivo | usare reset e avvio controllato |

## Checklist Finale Per La Classe

Alla fine della demo gli studenti dovrebbero saper spiegare:

- quali collection compongono il database `telemetry`;
- perché esistono sia raw sia curated;
- come il collector modifica il database;
- come si legge un documento MongoDB;
- come una aggregation pipeline diventa una card di dashboard;
- quali indici supportano le query principali;
- quali trade-off introduce una soluzione NoSQL rispetto a una relazionale.
