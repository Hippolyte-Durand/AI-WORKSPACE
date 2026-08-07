#!/usr/bin/env sh
# ai-workspace — link-project.sh <chemin-du-projet>
# Lie les skills de la source unique dans un projet donné.
# NB : les skills personnels sont déjà GLOBAUX (~/.gemini/skills +
# ~/.gemini/config/skills, voir install.sh) — ce script ne sert que pour
# du workspace-scoped explicite (ex. projet partagé, skills versionnés dans le repo).
# Antigravity lit <projet>/.agents/skills (docs actuelles) ; .agent/skills (sans S)
# est l'ancien chemin — on lie les deux pour compatibilité. Idempotent.
set -e
WS="$(cd "$(dirname "$0")" && pwd)"
PROJECT="${1:?usage: sh link-project.sh <chemin-du-projet>}"
[ -d "$PROJECT" ] || { echo "erreur: $PROJECT n'existe pas"; exit 1; }

for sub in .agents/skills .agent/skills .gemini/skills; do
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
