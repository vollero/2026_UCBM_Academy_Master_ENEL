#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source_root="${SOURCE_ROOT:-$(cd "$repo_root/.." && pwd)}"

if [[ "$source_root" == "$repo_root" ]]; then
  echo "Errore: source_root e repo_root coincidono." >&2
  exit 1
fi

for required in slides activities sql; do
  if [[ ! -e "$source_root/$required" ]]; then
    echo "Errore: materiale sorgente mancante: $source_root/$required" >&2
    exit 1
  fi
done

mkdir -p "$repo_root/slides/blocks" "$repo_root/activities" "$repo_root/sql" "$repo_root/docs" "$repo_root/manifest"

reset_release_dir() {
  local dir="$1"
  case "$dir" in
    "$repo_root"/*) ;;
    *)
      echo "Errore: directory non sicura per reset: $dir" >&2
      exit 1
      ;;
  esac
  rm -rf "$dir"
  mkdir -p "$dir"
}

copy_pdf_tree() {
  local src="$1"
  local dest="$2"
  if ! has_matching_file "$src" -name '*.pdf'; then
    echo "Errore: nessun PDF trovato in $src. Sync annullato." >&2
    exit 1
  fi
  reset_release_dir "$dest"
  find "$src" -type f -name '*.pdf' -print0 | while IFS= read -r -d '' file; do
    local rel="${file#$src/}"
    mkdir -p "$dest/$(dirname "$rel")"
    cp "$file" "$dest/$rel"
  done
}

copy_activity_tree() {
  local src="$1"
  local dest="$2"
  if ! has_matching_file "$src" \( -name '*.pdf' -o -name '*.md' -o -name '*.sql' \); then
    echo "Errore: nessuna attività trovata in $src. Sync annullato." >&2
    exit 1
  fi
  reset_release_dir "$dest"
  find "$src" -type f \( -name '*.pdf' -o -name '*.md' -o -name '*.sql' \) -print0 | while IFS= read -r -d '' file; do
    local rel="${file#$src/}"
    mkdir -p "$dest/$(dirname "$rel")"
    cp "$file" "$dest/$rel"
  done
}

copy_sql_tree() {
  local src="$1"
  local dest="$2"
  if ! has_matching_file "$src" -name '*.sql'; then
    echo "Errore: nessuno script SQL trovato in $src. Sync annullato." >&2
    exit 1
  fi
  reset_release_dir "$dest"
  find "$src" -type f -name '*.sql' -print0 | while IFS= read -r -d '' file; do
    local rel="${file#$src/}"
    mkdir -p "$dest/$(dirname "$rel")"
    cp "$file" "$dest/$rel"
  done
}

has_matching_file() {
  local src="$1"
  shift
  local found
  found="$(find "$src" -type f "$@" -print -quit)"
  [[ -n "$found" ]]
}

copy_pdf_tree "$source_root/slides/blocks" "$repo_root/slides/blocks"
copy_activity_tree "$source_root/activities" "$repo_root/activities"
copy_sql_tree "$source_root/sql" "$repo_root/sql"

if [[ -f "$source_root/docker-compose.yml" ]]; then
  cp "$source_root/docker-compose.yml" "$repo_root/docker-compose.yml"
fi

rm -f "$repo_root/docs/source-material-index.md" "$repo_root/docs/workflow-docente.md"

{
  echo "# Elenco tecnico dei materiali della repository"
  echo "# Generated at: $(date -Iseconds)"
  echo -e "path\tbytes"
  (
    cd "$repo_root"
    for path in README.md docker-compose.yml slides activities sql docs; do
      [[ -e "$path" ]] && find "$path" -type f
    done | sort | while IFS= read -r file; do
      bytes="$(wc -c < "$file" | tr -d ' ')"
      printf '%s\t%s\n' "$file" "$bytes"
    done
  )
} > "$repo_root/manifest/materials.tsv"

echo "Sync completato in: $repo_root"
