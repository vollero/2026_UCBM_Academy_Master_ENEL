# Guida Studenti

Questa repository raccoglie il materiale del corso **Relational Databases & SQL**, con una parte finale dedicata a NoSQL e MongoDB.

Il materiale è organizzato per blocchi. Ogni blocco corrisponde a una parte del percorso didattico e contiene slide, attività ed eventuali script SQL o NoSQL.

## Come Usare Il Materiale

Per ogni blocco:

1. aprite il PDF delle slide in `slides/blocks/<blocco>/`;
2. leggete l'handout dell'attività in `activities/<blocco>/`;
3. se il blocco prevede SQL, eseguite gli script `.sql` nel container PostgreSQL Docker del laboratorio;
4. se il blocco prevede NoSQL operativo, eseguite gli script `.js` nel container MongoDB Docker del laboratorio;
5. usate i file Markdown come traccia rapida o come riferimento testuale.

## Materiali Principali

- Slide della lezione: `slides/blocks/<blocco>/<blocco>.pdf`
- Traccia pratica: `activities/<blocco>/activity.md`
- PDF attività: `activities/<blocco>/<blocco>_activity.pdf`
- Soluzioni e script SQL/NoSQL: disponibili nelle cartelle `activities/<blocco>/` quando previsti
- Script generali di laboratorio: `sql/`
- Script generali NoSQL: `nosql/`
- Ambiente Docker del laboratorio: `docker-compose.yml`
- Comandi rapidi Docker/PostgreSQL/MongoDB: `docs/comandi-laboratorio-docker.md`
- Guida operativa piattaforme: `docs/guida-operativa-piattaforme.md`
- Query SQL pronte per copia/incolla: `docs/query-copia-incolla.md`

## Materiali Aggiuntivi

Alcuni blocchi includono anche materiali introduttivi o casi studio:

- blocco 3: casi di studio e guida PostgreSQL in Docker;
- blocco 4: introduzione progressiva alle prime query SQL;
- blocco 5: introduzione progressiva ai `JOIN`;
- blocchi 6-12: introduzioni progressive ai costrutti SQL avanzati;
- blocchi 4-8: esercitazioni Docker con query da costruire a partire da rappresentazioni tabellari.
- blocchi 13-14: introduzione a tecnologie, modelli e scenari NoSQL;
- blocchi 15-16: laboratorio MongoDB su un sistema di telemetria con collector simulato e dashboard.

## Per Lavorare Con SQL

Il laboratorio del corso usa PostgreSQL in Docker. Non serve installare PostgreSQL direttamente sul computer: serve Docker avviato e il container definito in `docker-compose.yml`.

La procedura è descritta in [setup-laboratorio.md](setup-laboratorio.md).

Per avvio, stop e interazione controllata con le piattaforme usate [guida-operativa-piattaforme.md](guida-operativa-piattaforme.md).

Per copia/incolla rapido durante il laboratorio usate [comandi-laboratorio-docker.md](comandi-laboratorio-docker.md).

## Per Lavorare Con NoSQL

I blocchi 15-16 usano MongoDB in Docker. Lo stack è definito in `docker-compose.telemetry.yml` e include:

- MongoDB, il DBMS NoSQL del laboratorio;
- un collector simulato che genera letture di telemetria;
- mongo-express, una piccola interfaccia web per ispezionare database e collezioni.

La guida dedicata è [architettura-telemetria.md](architettura-telemetria.md).

## Convenzioni Usate Nel Corso

- Una query va letta partendo dalla domanda: che cosa voglio ottenere?
- Prima di scrivere SQL bisogna chiarire la granularità: una riga per cosa?
- I nomi delle tabelle e delle colonne vanno letti come parte del modello.
- Quando una query usa più tabelle, è utile controllare se il numero di righe cambia.
- Quando una query aggrega, è importante chiarire popolazione, denominatore e metrica.
