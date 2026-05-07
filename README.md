# Relational Databases & SQL - Materiale studenti

Questa repository contiene il materiale rilasciabile agli studenti per il corso **Relational Databases & SQL**.

Il materiale sorgente del docente resta nella cartella padre. Questa repo contiene una copia pulita dei file da distribuire: PDF, tracce, handout, script SQL ed eventuali materiali aggiuntivi.

## Struttura

- `slides/blocks/`: PDF delle lezioni e slide aggiuntive.
- `activities/`: tracce, handout PDF, soluzioni e script SQL collegati ai blocchi.
- `sql/`: script PostgreSQL di laboratorio.
- `docs/`: note operative e indice copiato dal materiale sorgente.
- `manifest/materials.tsv`: elenco generato dei file rilasciati.
- `scripts/`: script per sincronizzare e verificare il rilascio.

## Aggiornare la repo dal materiale sorgente

Dalla cartella padre, rigenerare prima i PDF:

```bash
make
make extras
```

Poi entrare nella repo studenti e sincronizzare:

```bash
cd student-release
make sync
make check
git status
```

Quando il risultato è corretto:

```bash
git add .
git commit -m "Aggiorna materiale studenti"
```

## Regola di manutenzione

Non modificare manualmente i file dentro `slides/`, `activities/` e `sql/`: vengono sovrascritti da `make sync`.

Le modifiche manuali vanno fatte nei sorgenti del corso, nella cartella padre. Questa repo deve restare una fotografia pulita e versionata del materiale rilasciato.

