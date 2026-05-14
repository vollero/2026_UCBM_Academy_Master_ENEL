# Panoramica comparativa delle soluzioni NoSQL

Materiale aggiuntivo per i blocchi 13-16.

## Obiettivo

NoSQL non indica un singolo prodotto e non indica una scelta automaticamente migliore di SQL. Indica una famiglia di tecnologie nate per gestire problemi in cui forma del dato, volume, velocità, distribuzione o tipo di interrogazione rendono utile un modello diverso da quello tabellare classico.

La domanda corretta non è:

> Qual è il database migliore?

La domanda corretta è:

> Quale modello dati serve meglio questo access pattern, con quali garanzie e con quali costi?

## Dimensioni da confrontare

| Dimensione | Domanda pratica | Perché conta |
| --- | --- | --- |
| Forma del dato | Il dato è tabellare, documento, relazione, testo, serie temporale o vettore? | Ogni famiglia NoSQL rende naturale una forma diversa. |
| Letture principali | Come verrà letto il dato nel 90% dei casi? | In NoSQL si modella spesso partendo dalle query. |
| Scritture | Le scritture sono rare, continue, a burst o distribuite? | Alcuni sistemi sono ottimizzati per ingest continuo. |
| Consistenza | Serve vedere subito l'ultimo aggiornamento? | Alcune architetture accettano consistenza eventuale. |
| Scalabilità | Il problema cresce per utenti, eventi, regioni o dimensione dei documenti? | La strategia di partizionamento cambia il modello. |
| Operatività | Chi gestisce backup, replica, sicurezza, monitoring e upgrade? | Una tecnologia efficace ma ingestibile è una cattiva scelta. |
| Costo dell'errore | Che cosa succede se il dato è lento, duplicato o temporaneamente incoerente? | Il rischio applicativo guida i compromessi. |

## Matrice sintetica delle famiglie

| Famiglia | Unità naturale | Query tipica | Scenari adatti | Attenzione a |
| --- | --- | --- | --- | --- |
| Document database | Documento JSON/BSON | Lettura o aggiornamento di un aggregate | Cataloghi, profili, eventi semi-strutturati, configurazioni | Documenti troppo grandi, duplicazione non governata, relazioni nascoste |
| Key-value store | Coppia chiave-valore | Lookup diretto per chiave | Sessioni, cache, token, carrelli, rate limiting | Query quasi assenti, invalidazione cache, dati fuori sincronia |
| Wide-column store | Partizione e righe ordinate | Range query dentro una partizione | Timeline massive, metriche, log, eventi distribuiti | Query non previste, hot partition, consistenza eventuale |
| Graph database | Nodo e relazione | Attraversamento di cammini e dipendenze | Frodi, reti, asset, raccomandazioni, impatto guasti | Poco utile se le relazioni sono semplici o poco profonde |
| Search engine | Documento indicizzato | Full-text, ranking, facet, filtri | Manuali, ticket, log analytics, audit, knowledge base | Non è di solito il system of record transazionale |
| Time-series database | Misura con timestamp | Finestre temporali, downsampling, retention | Monitoring, IoT, energia, osservabilità | Poco adatto a workflow transazionali generici |
| Vector database | Embedding | Ricerca per similarità | RAG, ricerca semantica, deduplicazione, suggerimenti | Qualità degli embedding, aggiornamento dell'indice, spiegabilità |

## Famiglia 1: document database

Un database documentale memorizza record come documenti strutturati, spesso simili a JSON. Il documento può contenere campi annidati e array.

Esempio concettuale:

```json
{
  "order_id": "ORD-2026-1001",
  "customer": {
    "id": "C-42",
    "segment": "business"
  },
  "status": "shipped",
  "items": [
    { "sku": "BAT-10", "qty": 3, "unit_price": 129.0 },
    { "sku": "INV-02", "qty": 1, "unit_price": 880.0 }
  ]
}
```

Funziona bene quando l'applicazione legge e scrive quasi sempre l'oggetto completo. Per esempio, un ordine con le righe ordine può essere letto come aggregate unico.

È meno adatto quando le relazioni diventano molte, profonde e variabili. Se il codice applicativo inizia a ricostruire join manualmente, il modello documentale sta probabilmente diventando forzato.

## Famiglia 2: key-value e cache

Un key-value store è il modello più semplice: a una chiave corrisponde un valore.

| Chiave | Valore |
| --- | --- |
| `session:user:928` | stato della sessione utente |
| `cart:user:928` | carrello corrente |
| `rate:api:client-77` | contatore richieste/minuto |
| `feature:new-dashboard` | flag applicativo |
| `kpi:region:north:today` | KPI precomputato |

È utile quando la chiave è nota e si vuole una risposta molto rapida. Spesso non sostituisce il database principale: lo affianca.

Il problema tipico è l'invalidazione. Se il dato originale cambia, chi aggiorna la cache? Con quale ritardo? Che cosa succede se la cache contiene una copia vecchia?

## Famiglia 3: wide-column

Un wide-column store organizza il dato per partizioni. La progettazione parte dalla domanda:

> Quali righe leggerò insieme?

Esempio concettuale:

```sql
CREATE TABLE readings_by_device_day (
  device_id text,
  day date,
  ts timestamp,
  value double,
  status text,
  PRIMARY KEY ((device_id, day), ts)
);
```

La chiave non descrive solo l'identità della riga. Descrive anche distribuzione, ordinamento e access pattern.

È adatto a scritture continue, query note e scala orizzontale. È meno adatto a interrogazioni improvvisate, perché una nuova domanda può richiedere una nuova vista fisica del dato.

## Famiglia 4: graph database

Un graph database rappresenta la realtà come nodi, relazioni e proprietà.

Esempi di domande naturali:

- quali clienti sono collegati allo stesso asset?
- quali cabine dipendono da una linea?
- quali fornitori condividono contatti, indirizzi o dispositivi?
- se questo asset fallisce, quali zone possono essere impattate?

Il grafo è utile quando la relazione non è solo un vincolo tra tabelle, ma diventa il centro della domanda.

Non serve introdurre un graph database solo per evitare join normali. Serve quando i cammini, le dipendenze e le connessioni indirette sono frequenti e importanti.

## Famiglia 5: search engine

Un motore di ricerca indicizza documenti per full-text search, ranking, facet e filtri.

| Richiesta | Perché search è adatto |
| --- | --- |
| "trova ticket simili" | ranking testuale e scoring |
| "cerca manuali su inverter" | full-text e facet per categoria |
| "filtra log per errore e servizio" | ingest e query su messaggi semi-strutturati |
| "mostra eventi anomali" | aggregazioni rapide sull'indice |

Il motore di ricerca è spesso una vista derivata. Il dato ufficiale resta altrove, ma viene copiato e indicizzato per rendere veloce una famiglia specifica di interrogazioni.

## Famiglia 6: time-series

Un time-series database ottimizza dati misurati nel tempo: ingest, compressione, retention e query su finestre temporali.

Esempi:

- metriche infrastrutturali;
- dati industriali;
- consumi energetici;
- monitoring e alerting;
- downsampling giornaliero, orario o mensile.

Nel laboratorio dei blocchi 15-16 useremo MongoDB per ragionare sul documento e sulla pipeline. In produzione, per alcuni carichi di telemetria molto intensi, avrebbe senso valutare anche un database time-series.

## Famiglia 7: vector database

Un vector database cerca oggetti simili nello spazio degli embedding. Non cerca righe uguali e non cerca solo parole identiche.

Esempi:

- ricerca semantica in documenti tecnici;
- recupero di contesto per applicazioni RAG;
- deduplicazione di ticket simili;
- suggerimento di interventi precedenti;
- clustering di incidenti.

La qualità del risultato dipende dalla qualità degli embedding, dal modello usato per generarli e dal modo in cui si aggiorna l'indice.

## Scenari applicativi motivati

### Catalogo energetico

Problema: gestire prodotti e servizi con attributi molto diversi: pannelli, inverter, batterie, contratti, manutenzioni.

Scelta possibile:

| Esigenza | Tecnologia candidata |
| --- | --- |
| Schede prodotto flessibili | Document database |
| Ricerca per testo e filtri | Search engine |
| Prezzi, ordini, fatture | Relazionale |
| Disponibilità letta spesso | Cache/key-value |

Non serve scegliere una sola tecnologia. Il catalogo può usare un document database per la scheda flessibile, ma il ciclo ordine-fattura resta naturalmente relazionale.

### Customer care

Problema: un operatore deve trovare rapidamente ticket simili, storico cliente, documenti tecnici ed escalation.

Scelta possibile:

| Esigenza | Tecnologia candidata |
| --- | --- |
| Stato ufficiale ticket e SLA | Relazionale |
| Note, email, manuali | Search engine |
| Similarità semantica tra problemi | Vector database |
| Relazioni cliente-impianto-asset | Graph database |

Questo scenario mostra perché il modello "un database per tutto" diventa stretto: la stessa schermata ha bisogno di dati ufficiali, testo ricercabile, similarità e relazioni.

### Frodi e anomalie contrattuali

Problema: individuare connessioni non evidenti tra contratti, pagamenti, indirizzi, dispositivi e referenti.

Scelta possibile:

| Esigenza | Tecnologia candidata |
| --- | --- |
| Contratti e pagamenti ufficiali | Relazionale |
| Connessioni indirette | Graph database |
| Note e documenti allegati | Search engine |
| Scoring e feature analitiche | Analytical store o feature store |

Il grafo aiuta perché l'informazione importante non è solo nel singolo record, ma nelle connessioni tra record.

### Observability di una piattaforma

Problema: monitorare microservizi, metriche, log, errori e alert.

Scelta possibile:

| Esigenza | Tecnologia candidata |
| --- | --- |
| Metriche numeriche nel tempo | Time-series |
| Log applicativi | Search/log analytics |
| Rate limit e stato temporaneo | Key-value |
| Dashboard operative | Read model specializzato |

In questo scenario il database operativo dell'applicazione non deve diventare anche il sistema di osservabilità. Sono carichi diversi.

## Checklist per decidere

Prima di proporre una soluzione NoSQL, completare queste frasi:

1. Il dato principale ha forma ...
2. La query più importante è ...
3. La scrittura principale avviene ...
4. La consistenza richiesta è ...
5. Il dato autorevole si trova in ...
6. Le copie derivate sono ...
7. Se questa tecnologia non è disponibile, l'impatto è ...
8. Il costo operativo principale è ...

## Errori frequenti

- Scegliere NoSQL perché "scala" senza misurare il problema reale.
- Usare documenti come se fossero tabelle, senza ripensare gli access pattern.
- Duplicare dati senza dichiarare quale copia è autorevole.
- Ignorare consistenza eventuale e ritardi di propagazione.
- Sottovalutare backup, monitoring, sicurezza e migrazioni.
- Introdurre troppe tecnologie prima di avere un bisogno chiaro.

## Attività di discussione

Per ciascuno scenario scegliere una o più famiglie NoSQL e motivare la scelta:

1. portale per manuali tecnici e ticket simili;
2. dashboard di consumi energetici ogni minuto;
3. sistema di sessioni e rate limiting per API;
4. analisi di dipendenze tra asset di rete;
5. catalogo prodotti con attributi variabili per categoria.

Per ogni scelta indicare:

- access pattern principale;
- dato autorevole;
- eventuali copie derivate;
- vantaggio rispetto al solo database relazionale;
- trade-off introdotto.
