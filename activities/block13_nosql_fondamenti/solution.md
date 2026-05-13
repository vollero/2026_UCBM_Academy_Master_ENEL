# Soluzione - Blocco 13 - Fondamenti NoSQL

| Scenario | Scelta plausibile | Motivazione | Rischio |
| --- | --- | --- | --- |
| Catalogo prodotti | Document database | schede prodotto lette come documento completo, attributi variabili per categoria | duplicazione e query aggregate da progettare |
| Sessioni utente | Key-value store | accesso diretto per session id, TTL, latenza bassa | query quasi assenti, valore opaco |
| Telemetria | Document/time-series o wide-column | scritture frequenti, metriche variabili, query temporali | retention, indici temporali, cardinalità dispositivi |
| Dipendenze asset | Graph database | domande su impatti, connessioni e attraversamenti multi-hop | non adatto se servono solo aggregazioni semplici |

## Discussione
SQL resta molto adatto per dati core con integrità forte: contratti, fatturazione, anagrafiche master, autorizzazioni e processi transazionali. In un'architettura reale potremmo usare più storage: PostgreSQL per il core transazionale, MongoDB per eventi telemetrici, Redis per cache e un motore search per log o testo.

## Risposta attesa
Una risposta corretta non deve coincidere perfettamente con la tabella, ma deve collegare ogni scelta a:

- forma del dato;
- operazioni frequenti;
- garanzie richieste;
- rischio o compromesso.
