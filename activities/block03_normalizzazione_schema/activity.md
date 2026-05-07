# Blocco 3 - Normalizzazione e schema relazionale

## 1. Problema in forma informale
Il dataset iniziale arriva come tabella piatta perché cosi è stato esportato dal gestionale. Il compito è trasformarlo in uno schema robusto prima di scrivere SQL operativo.

## 2. Specifica corretta del problema
- input: elenco colonne di una tabella vendite denormalizzata;
- output: schema normalizzato con relazioni, chiavi e riferimenti;
- vincolo: non perdere dati storici necessari alle analisi;
- vincolo: motivare ogni dipendenza funzionale usata per scomporre.

## 3. Definizione della soluzione
1. individuare entità stabili: cliente, prodotto;
2. individuare eventi: ordine, riga ordine, spedizione;
3. spostare attributi descrittivi nella relazione determinante;
4. lasciare nella riga ordine prezzo e sconto storici.

## 4. Implementazione completa o artefatto atteso
Per questo blocco l'implementazione è un artefatto di modellazione, non uno script SQL.

- `customers`: dati anagrafici e segmentazione cliente
- `products`: descrizione prodotto e categoria
- `orders`: testata ordine e stato
- `order_items`: dettaglio prodotto, quantità, prezzo storico, sconto
- `shipments`: stato logistico collegato all'ordine
- `support_tickets`: richieste cliente collegate opzionalmente a un ordine

## 5. Criteri di verifica
- ogni relazione rappresenta un solo tipo di fatto;
- gli attributi descrittivi dipendono dalla chiave corretta;
- il report originale è ricostruibile tramite join;
- eventuali denormalizzazioni sono motivate da un uso concreto.

## 6. Checkpoint
- normalizzare significa spostare informazioni nel posto dove hanno identità propria;
- la forma normale non è un rito: serve a prevenire anomalie concrete;
- una denormalizzazione si decide dopo aver capito la normalizzazione.
