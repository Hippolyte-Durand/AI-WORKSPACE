#!/usr/bin/env sh
# ai-workspace — bootstrap des symlinks sur machine neuve (idempotent).
# Source unique = ce repo. Les CLIs ne reçoivent que des liens, jamais de copies.
# Usage : sh install.sh
set -e
WS="$(cd "$(dirname "$0")" && pwd)"

# Lie chaque skill de $WS/skills dans $1 (un symlink PAR skill, jamais le dossier
# entier : certains CLIs écrivent du runtime dans leur dossier skills).
# Une vraie copie existante n'est remplacée que si identique à la source.
link_skills_into() {
  mkdir -p "$1"
  for s in "$WS"/skills/*/; do
    name="$(basename "$s")"
    t="$1/$name"
    if [ -e "$t" ] && [ ! -L "$t" ]; then
      if diff -rq "$t" "$s" >/dev/null 2>&1; then
        rm -rf "${t:?}"
      else
        echo "[install] CONSERVÉ (diffère de la source): $t"
        continue
      fi
    fi
    ln -sfn "${s%/}" "$t"
  done
}

# --- Claude Code ---
# Symlinks par FICHIER/dossier de config, jamais ~/.claude entier (runtime :
# sessions, caches, .system/). settings.local.json reste local, hors repo.
mkdir -p "$HOME/.claude"
for x in settings.json CLAUDE.md RTK.md hooks agents agents-drafts; do
  [ -e "$WS/config/claude/$x" ] && ln -sfn "$WS/config/claude/$x" "$HOME/.claude/$x"
done
# Claude injecte du .system/ dans ~/.claude/skills → liens par skill.
link_skills_into "$HOME/.claude/skills"

# --- Kimi Code ---
# Même format SKILL.md → lien direct vers la source partagée.
KIMI_HOME="${KIMI_CODE_HOME:-$HOME/.kimi-code}"
mkdir -p "$KIMI_HOME"
ln -sfn "$WS/skills" "$KIMI_HOME/skills"
# MCP (qmd + supabase) + config agent/TUI — même format, liens directs.
# (les tokens OAuth vivent dans $KIMI_HOME/oauth/, hors repo)
for f in mcp.json config.toml tui.toml; do
  [ -e "$WS/config/kimi/$f" ] && ln -sfn "$WS/config/kimi/$f" "$KIMI_HOME/$f"
done

# --- Antigravity (CLI Google, sur abonnement) : skills GLOBAUX ---
# ~/.gemini/config/skills = seul chemin reconnu par les 3 flavours Antigravity
#                           (AGY, AGY CLI, AGY IDE — tests empiriques, juil. 2026)
# Gemini CLI n'est PAS configuré ici : il passe par API payante, inutilisé.
# (son user scope serait ~/.gemini/skills, son hook RTK via config/gemini/hooks.json
#  — retirés le 2026-08-07, récupérables dans l'historique git si besoin)
link_skills_into "$HOME/.gemini/config/skills"

echo "[ai-workspace] symlinks en place. Redémarrer les CLIs pour prise en compte."
