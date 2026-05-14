# Oltre il modello DB singolo + business logic + interfaccia

Materiale aggiuntivo per i blocchi 13-16.

## Obiettivo

Il modello iniziale:

```text
interfaccia -> business logic -> database
```

è utile per iniziare. È semplice da spiegare, sviluppare, testare e distribuire.

Nei sistemi grandi, però, il database singolo rischia di diventare responsabile di tutto:

- transazioni;
- report;
- dashboard;
- ricerca testuale;
- log;
- allegati;
- relazioni profonde;
- dati temporali;
- dati semi-strutturati;
- integrazioni tra team.

Il punto della lezione non è dire che il modello semplice sia sbagliato. Il punto è capire quando diventa limitante e quali paradigmi permettono di evolverlo.

## Quando il modello semplice funziona bene

| Condizione | Perché il modello regge |
| --- | --- |
| Dominio piccolo o medio | Lo schema resta comprensibile. |
| Team unico | Le decisioni sono coordinate. |
| Carico prevedibile | Il DB non viene stressato da pattern incompatibili. |
| Query abbastanza omogenee | Lo stesso modello serve bene più schermate. |
| Dati principalmente tabellari | Il relazionale è naturale. |
| Requisiti di disponibilità ordinari | Replica, backup e monitoring bastano. |

In questa fase un database relazionale può essere la scelta più solida: vincoli, transazioni, SQL, integrità e strumenti maturi.

## Segnali che il modello diventa stretto

| Segnale | Conseguenza pratica |
| --- | --- |
| Molti casi d'uso diversi | Un solo schema deve servire domande troppo diverse. |
| Scritture ad alto volume | Report e transazioni si disturbano. |
| Ricerca testuale complessa | SQL diventa artificiale o lento. |
| Relazioni profonde | Le query diventano ricorsive, pesanti o difficili da mantenere. |
| Dashboard quasi real-time | Il carico analitico pesa sul DB operativo. |
| Team multipli | Deploy, ownership e schema diventano accoppiati. |
| Dati semi-strutturati | Lo schema tabellare cambia troppo spesso. |

Analogia: un piccolo ufficio può usare un unico armadio per tutto. Quando l'organizzazione cresce, contratti, manuali, log, mappe, allegati e dashboard richiedono archivi e strumenti diversi.

## Paradigma 1: polyglot persistence

Polyglot persistence significa usare più tecnologie di persistenza nello stesso sistema, ciascuna scelta per uno specifico modello dati o access pattern.

| Tecnologia | Responsabilità tipica |
| --- | --- |
| Relazionale | Dati core, vincoli, transazioni, stati ufficiali |
| Document database | Aggregate flessibili, moduli variabili, eventi JSON |
| Search engine | Testo, log, ranking, facet, investigazioni |
| Graph database | Dipendenze, cammini, relazioni indirette |
| Key-value/cache | Sessioni, lock, rate limit, letture frequenti |
| Time-series | Metriche, segnali temporali, retention |
| Warehouse/lake | Storico analitico e reporting pesante |

La scelta non è più "SQL oppure NoSQL". La scelta diventa:

> Quale componente deve essere autorevole? Quale componente deve essere veloce per una lettura specifica? Quale copia può essere derivata?

## Paradigma 2: architettura event-driven

In una architettura event-driven i componenti pubblicano eventi:

- `ticket.created`;
- `ticket.priority_changed`;
- `asset.updated`;
- `work_order.closed`;
- `manual.indexed`;
- `reading.ingested`.

Gli eventi permettono a più consumatori di costruire viste diverse senza bloccare il flusso principale.

Esempio:

```json
{
  "event_type": "ticket.created",
  "ticket_id": "T-2026-90012",
  "opened_at": "2026-05-14T09:20:00Z",
  "category": "outage",
  "region": "center",
  "asset_hint": "CAB-1821",
  "priority": "urgent"
}
```

Lo stesso evento può aggiornare:

| Consumer | Trasformazione | Store |
| --- | --- | --- |
| `search-indexer` | Indicizza descrizione e metadati | Search engine |
| `asset-linker` | Collega ticket ad asset e zone | Graph database |
| `dashboard-projector` | Aggiorna KPI per regione | Read model |
| `notification-service` | Avvisa squadre operative | Queue/cache |
| `workorder-service` | Prepara un modulo intervento | Document database |

## Paradigma 3: CQRS e read model

CQRS significa separare il modello usato per scrivere dal modello usato per leggere.

| Parte | Scopo |
| --- | --- |
| Command model | Scrivere correttamente, validare regole, proteggere invarianti |
| Read model | Leggere velocemente in una forma vicina alla schermata o dashboard |
| Event stream | Propagare cambiamenti tra modelli |
| Projection | Trasformare eventi in viste consultabili |

La separazione è utile quando la forma migliore per scrivere non è la forma migliore per leggere.

Esempio: un ticket deve essere scritto rispettando stati e SLA, ma la dashboard vuole conteggi già aggregati per regione, priorità e finestra temporale.

## Caso oltre la telemetria: gestione guasti e interventi

Il laboratorio di telemetria dei blocchi 15-16 resta valido e va preservato. È un buon caso per discutere documenti, metriche, ingest e aggregation pipeline.

Per mostrare un sistema più ampio, consideriamo un altro scenario: gestione guasti e interventi sul campo in una utility energetica.

### Scenario informale

Dopo un evento meteo arrivano segnalazioni di guasto da clienti, tecnici, sistemi interni e canali partner. L'azienda deve capire:

- quali segnalazioni sono aperte;
- quali asset sono coinvolti;
- quali clienti o zone sono impattati;
- quali squadre sono disponibili;
- quali manuali o interventi passati sono rilevanti;
- quali KPI deve vedere il responsabile operativo.

Non è solo telemetria. È coordinamento operativo, documenti, asset, relazioni, ricerca e workflow.

### Limite del database unico

| Esigenza | Problema se tutto resta nello stesso DB |
| --- | --- |
| Workflow ticket | Gestibile, ma cresce la complessità dello schema. |
| Documenti tecnici | Ricerca testuale debole o costosa. |
| Topologia asset | Join ricorsive e query difficili. |
| Foto e allegati | Storage e backup poco adatti. |
| Dashboard operative | Carico analitico sul DB transazionale. |
| Suggerimenti su interventi simili | Servono ranking e similarità. |

### Architettura proposta

| Componente | Tecnologia candidata | Responsabilità |
| --- | --- | --- |
| Ticket core | PostgreSQL | Stato ufficiale, SLA, vincoli |
| Work order form | Document DB | Moduli tecnici variabili |
| Asset topology | Graph DB | Dipendenze rete e impatto |
| Manuali e note | Search engine | Full-text e ranking |
| Sessioni e lock | Key-value | Stato temporaneo operativo |
| Event stream | Broker o queue | Propagazione cambiamenti |
| Dashboard | BI o read model | KPI e drill-down |

### Regola sulle copie

Duplicare dati non è vietato, ma bisogna dichiarare quale copia è autorevole e quale è derivata.

| Informazione | Copia autorevole | Copia derivata |
| --- | --- | --- |
| Stato ticket | PostgreSQL | Dashboard, search |
| Work order tecnico | Document DB | Dashboard, audit |
| Manuali | Document repository | Search index |
| Topologia asset | Sistema asset management o graph | Dashboard impatto |
| KPI operativi | Eventi + proiezioni | Cache/dashboard |

Se una vista derivata si corrompe, deve poter essere ricostruita dal dato autorevole o dagli eventi.

## Confronto con il caso telemetria

| Aspetto | Telemetria | Gestione guasti |
| --- | --- | --- |
| Dato principale | Lettura sensore | Ticket, asset, work order |
| Forma | Evento tecnico semi-strutturato | Workflow multi-oggetto |
| Query | Trend, KPI, alert | Stato, ricerca, impatto, assegnazione |
| Store centrale del laboratorio | MongoDB | Più store specializzati |
| Consistenza | Dashboard può tollerare ritardi | Alcune azioni richiedono forte controllo |
| Obiettivo didattico | Documenti e aggregazioni NoSQL | Architettura dati a componenti specializzati |

Il messaggio non è abbandonare il relazionale. Ticket, SLA, contratti, pagamenti e stati ufficiali restano spesso ottimi candidati per un DBMS relazionale.

NoSQL entra dove il modello relazionale diventa innaturale o troppo costoso per uno specifico access pattern.

## Costi e rischi

| Rischio | Pratica di controllo |
| --- | --- |
| Eventi incompatibili | Contratti versionati o schema registry |
| Duplicazione incontrollata | Source of truth dichiarata |
| Debug difficile | Correlation id e tracing |
| Ritardi tra store | Metriche di lag e retry idempotenti |
| Vista derivata corrotta | Replay eventi o job di backfill |
| Ownership confusa | Responsabilità esplicita per servizio e store |
| Costi fuori controllo | Monitoring di storage, richieste e retention |

## Domande architetturali

Per ogni sistema grande, provare a rispondere:

1. Qual è il system of record?
2. Quali viste sono derivate?
3. Quanto ritardo è accettabile tra scrittura e lettura?
4. Come ricostruisco una vista se si corrompe?
5. Come traccio quale evento ha aggiornato quale store?
6. Come gestisco rollback o compensazione?
7. Quale componente può fallire senza bloccare tutto?
8. Quale metrica mi dice che l'architettura funziona?

## Attività di discussione

Dato lo scenario gestione guasti e interventi:

1. individuare almeno tre dati autorevoli;
2. individuare almeno tre viste derivate;
3. scegliere una tecnologia candidata per ciascuna vista;
4. indicare quale consistenza serve;
5. indicare quale componente può essere ricostruito;
6. indicare un rischio operativo e una contromisura.

Output atteso:

- diagramma logico dei componenti;
- tabella source of truth / vista derivata;
- elenco degli eventi principali;
- motivazione delle tecnologie scelte;
- trade-off accettati.
