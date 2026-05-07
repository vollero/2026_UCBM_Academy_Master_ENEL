# Guida Studenti

Questa repository raccoglie il materiale del corso **Relational Databases & SQL**.

Il materiale è organizzato per blocchi. Ogni blocco corrisponde a una parte del percorso didattico e contiene slide, attività ed eventuali script SQL.

## Come Usare Il Materiale

Per ogni blocco:

1. aprite il PDF delle slide in `slides/blocks/<blocco>/`;
2. leggete l'handout dell'attività in `activities/<blocco>/`;
3. se il blocco prevede SQL, eseguite gli script `.sql` nel database di laboratorio;
4. usate i file Markdown come traccia rapida o come riferimento testuale.

## Materiali Principali

- Slide della lezione: `slides/blocks/<blocco>/<blocco>.pdf`
- Traccia pratica: `activities/<blocco>/activity.md`
- PDF attività: `activities/<blocco>/<blocco>_activity.pdf`
- Soluzioni e script SQL: disponibili nelle cartelle `activities/<blocco>/` quando previsti
- Script generali di laboratorio: `sql/`

## Materiali Aggiuntivi

Alcuni blocchi includono anche materiali introduttivi o casi studio:

- blocco 3: casi di studio e guida PostgreSQL in Docker;
- blocco 4: introduzione progressiva alle prime query SQL;
- blocco 5: introduzione progressiva ai `JOIN`;
- blocchi 6-12: introduzioni progressive ai costrutti SQL avanzati;
- blocchi 4-8: esercitazioni Docker con query da costruire a partire da rappresentazioni tabellari.

## Per Lavorare Con SQL

Potete usare PostgreSQL installato localmente oppure PostgreSQL in Docker.

La procedura con Docker è descritta in [setup-laboratorio.md](setup-laboratorio.md).

## Convenzioni Usate Nel Corso

- Una query va letta partendo dalla domanda: che cosa voglio ottenere?
- Prima di scrivere SQL bisogna chiarire la granularità: una riga per cosa?
- I nomi delle tabelle e delle colonne vanno letti come parte del modello.
- Quando una query usa più tabelle, è utile controllare se il numero di righe cambia.
- Quando una query aggrega, è importante chiarire popolazione, denominatore e metrica.

