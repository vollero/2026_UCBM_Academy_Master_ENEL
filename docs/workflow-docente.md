# Workflow di rilascio

Questa repo è pensata come area di pubblicazione del materiale studenti. Il materiale viene mantenuto nel progetto padre e sincronizzato qui quando è pronto per il rilascio.

## Procedura consigliata

1. Aggiornare slide, attività e script SQL nel progetto padre.
2. Compilare i PDF nel progetto padre.
3. Sincronizzare questa repo.
4. Verificare che i file minimi siano presenti.
5. Fare commit nella repo studenti.

Comandi:

```bash
cd ..
make
make extras

cd student-release
make sync
make check
git status
git add .
git commit -m "Aggiorna materiale studenti"
```

## Cosa viene sincronizzato

- PDF delle slide in `slides/blocks/`.
- PDF, Markdown e SQL delle attività in `activities/`.
- Script SQL generali in `sql/`.
- Indice del materiale sorgente in `docs/source-material-index.md`.
- Manifest del rilascio in `manifest/materials.tsv`.

## Cosa non viene sincronizzato

- Sorgenti LaTeX.
- Log e file ausiliari di compilazione.
- Script generatori del docente.
- Guida docente.
- Archivio storico delle slide.

## Allineamento

Il file `manifest/materials.tsv` viene rigenerato a ogni sync. È utile per controllare rapidamente che un commit abbia aggiunto, rimosso o aggiornato i materiali attesi.

Per vedere cosa cambierà prima del commit:

```bash
git status --short
git diff --stat
```

