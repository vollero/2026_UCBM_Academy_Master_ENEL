# Soluzione - Blocco 3 - Normalizzazione e schema relazionale

## Strategia
1. individuare entità stabili: cliente, prodotto;
2. individuare eventi: ordine, riga ordine, spedizione;
3. spostare attributi descrittivi nella relazione determinante;
4. lasciare nella riga ordine prezzo e sconto storici.

## Soluzione completa
- `customers`: dati anagrafici e segmentazione cliente
- `products`: descrizione prodotto e categoria
- `orders`: testata ordine e stato
- `order_items`: dettaglio prodotto, quantità, prezzo storico, sconto
- `shipments`: stato logistico collegato all'ordine
- `support_tickets`: richieste cliente collegate opzionalmente a un ordine

## Perché la soluzione è corretta
- ogni relazione rappresenta un solo tipo di fatto;
- gli attributi descrittivi dipendono dalla chiave corretta;
- il report originale è ricostruibile tramite join;
- eventuali denormalizzazioni sono motivate da un uso concreto.

## Errori da discutere
- normalizzare nomi di colonne senza capire le dipendenze;
- separare tabelle solo per categorie estetiche;
- perdere attributi storici necessari, come prezzo al momento dell'ordine;
- scambiare una vista/report per una relazione primaria.

## Checkpoint
- normalizzare significa spostare informazioni nel posto dove hanno identità propria;
- la forma normale non è un rito: serve a prevenire anomalie concrete;
- una denormalizzazione si decide dopo aver capito la normalizzazione.
