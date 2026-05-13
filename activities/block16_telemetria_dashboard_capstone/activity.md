# Blocco 16 - Dashboard e capstone NoSQL

## 1. Problema in forma informale
Bisogna completare il sistema di telemetria costruendo le query di dashboard: KPI, ultima lettura, trend, energia, ambiente, alert e controllo raw-curated.

## 2. Specifica corretta del problema
- input: database MongoDB `telemetry` già popolato;
- output: pipeline di aggregazione per dashboard e presentazione del sistema;
- vincolo: ogni card deve dichiarare la propria granularità;
- vincolo: usare `readings_curated` per le metriche dashboard;
- vincolo: includere almeno un controllo di qualità;
- vincolo: confrontare la soluzione NoSQL con il sistema ticketing relazionale.

## 3. Definizione della soluzione
1. eseguire `nosql/telemetry_dashboard_queries.js`;
2. associare ogni pipeline a una card;
3. spiegare il tipo di visualizzazione;
4. verificare raw-curated;
5. discutere limiti, indici e retention.

## 4. Implementazione completa
```bash
docker compose -f docker-compose.telemetry.yml up -d
docker exec rdnosql-telemetry-mongo mongosh /nosql/telemetry_schema.js
docker exec rdnosql-telemetry-mongo mongosh /nosql/telemetry_dashboard_queries.js
```

## 5. Card minime
- KPI generale: letture, dispositivi, warning;
- ultima lettura per dispositivo;
- trend a bucket di 5 minuti;
- metriche energia per sito;
- metriche ambiente per sito;
- alert recenti;
- controllo raw-curated.

## 6. Criteri di verifica
- le pipeline vengono eseguite senza errori;
- le card usano la collection giusta;
- la granularità è dichiarata;
- i valori nulli sono interpretati correttamente;
- il controllo raw-curated è presente;
- il confronto SQL/NoSQL è motivato.
