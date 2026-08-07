#!/usr/bin/env sh
# ai-workspace — link-project.sh <chemin-du-projet>
# Lie les skills de la source unique dans un projet pour Gemini (.gemini/skills)
# et Antigravity (.agent/skills). Ces CLIs n'ont pas de dossier skills global :
# la distribution est forcément par projet. Idempotent.
# Claude est ignoré ici : ~/.claude/skills est déjà global (voir install.sh).
set -e
WS="$(cd "$(dirname "$0")" && pwd)"
PROJECT="${1:?usage: sh link-project.sh <chemin-du-projet>}"
[ -d "$PROJECT" ] || { echo "erreur: $PROJECT n'existe pas"; exit 1; }

for sub in .gemini/skills .agent/skills; do
  target_dir="$PROJECT/$sub"
  mkdir -p "$target_dir"
  for s in "$WS"/skills/*/; do
    name="$(basename "$s")"
    t="$target_dir/$name"
    if [ -e "$t" ] && [ ! -L "$t" ]; then
      # Vraie copie présente : ne la remplace que si identique à la source
      if diff -rq "$t" "$s" >/dev/null 2>&1; then
        rm -rf "${t:?}"
      else
        echo "CONSERVÉ (diffère de la source): $t"
        continue
      fi
    fi
    ln -sfn "${s%/}" "$t"
  done
  echo "[link-project] $sub → $(find "$target_dir" -maxdepth 1 -type l | wc -l | tr -d ' ') liens"
done
