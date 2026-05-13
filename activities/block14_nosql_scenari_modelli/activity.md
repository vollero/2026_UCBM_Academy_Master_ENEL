# Blocco 14 - Scenari e modellazione NoSQL

## 1. Problema in forma informale
Bisogna progettare un modello documentale per telemetria energetica e ambientale. I dispositivi inviano metriche diverse, ma la dashboard deve mostrare ultime letture, warning, trend e controlli di qualità.

## 2. Specifica corretta del problema
- input: descrizione di dispositivi e query dashboard;
- output: collection, documento esempio, indici e rischi;
- vincolo: distinguere dati raw e dati curati;
- vincolo: motivare embedding, reference e duplicazione;
- vincolo: indicare almeno tre indici coerenti con le query.

## 3. Definizione della soluzione
1. scrivere gli access pattern;
2. definire collection `devices`, `readings_raw`, `readings_curated`, `alerts`;
3. disegnare un documento raw e uno curated;
4. indicare gli indici;
5. discutere retention e qualità dati.

## 4. Access pattern minimi
- ultima lettura per dispositivo;
- letture per dispositivo in intervallo temporale;
- warning recenti;
- media temperatura per sito;
- conteggio raw e curated;
- alert per severità.

## 5. Suggerimenti
- Non incorporare tutte le letture nel documento dispositivo.
- Duplicare `site` e `region` nella lettura curata può essere corretto.
- Il campo `metrics` può restare variabile.
- Gli indici devono seguire `device_id`, `ts`, `region`, `device_type` e `severity`.

## 6. Criteri di verifica
- il modello serve le query principali;
- la duplicazione è motivata;
- raw e curated hanno responsabilità diverse;
- ogni indice ha una query target;
- i rischi sono dichiarati.
