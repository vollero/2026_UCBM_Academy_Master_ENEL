# Blocco 13 - Fondamenti NoSQL

## 1. Problema in forma informale
Un team deve scegliere una tecnologia dati per quattro nuovi servizi: catalogo prodotti flessibile, sessioni utente, telemetria dispositivi e analisi relazioni tra asset. Non basta dire "NoSQL": bisogna capire quale famiglia risolve quale problema.

## 2. Specifica corretta del problema
- input: descrizione di quattro scenari applicativi;
- output: scelta motivata della famiglia NoSQL per ogni scenario;
- vincolo: la scelta deve citare almeno due access pattern;
- vincolo: bisogna dichiarare un rischio o limite per ogni scelta;
- vincolo: quando SQL resta più adatto, va detto esplicitamente.

## 3. Definizione della soluzione
1. identificare la forma prevalente del dato;
2. scrivere le query o operazioni più frequenti;
3. scegliere tra document, key-value, wide-column, graph, search/time-series;
4. motivare la scelta;
5. indicare un rischio tecnico.

## 4. Scenari da risolvere
| Scenario | Descrizione sintetica |
| --- | --- |
| Catalogo prodotti | attributi diversi per categoria e lettura della scheda completa |
| Sessioni utente | accesso per session id, TTL e latenza bassa |
| Telemetria | messaggi frequenti da dispositivi con metriche variabili |
| Dipendenze asset | nodi, relazioni e domande su impatti multi-hop |

## 5. Suggerimenti
- Non scegliere una tecnologia partendo dal nome commerciale.
- Prima scrivere: "la query più importante è...".
- Se servono transazioni forti tra entità core, considerare un DBMS relazionale.
- Se il dato è letto sempre come oggetto completo, pensare a documenti.
- Se la domanda principale è attraversare relazioni, pensare a grafi.

## 6. Criteri di verifica
- ogni scenario ha una famiglia NoSQL motivata;
- ogni scelta cita access pattern concreti;
- almeno un caso discute perché SQL potrebbe restare necessario;
- i rischi sono realistici: consistenza, duplicazione, query limitate, hot partition, costo operativo.
