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
  # purge les liens morts (skills retirés/déplacés depuis le dernier run)
  find "$1" -maxdepth 1 -type l ! -exec test -e {} \; -delete 2>/dev/null
  # récursif : un skill = un dossier contenant SKILL.md, à n'importe quelle
  # profondeur (source rangée par thème). Le CLI reçoit toujours du PLAT.
  find "$WS/skills" -name SKILL.md | while read -r f; do
    s="$(dirname "$f")"
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
    ln -sfn "$s" "$t"
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
# Commands Claude (cycle de vie addy : /spec /plan /build /test /review /ship…)
# — liens par fichier. Les skills restent invoquables par /nom dans les 3 CLIs ;
# ces commands sont la couche routing du cycle, format spécifique Claude.
if [ -d "$WS/commands/claude" ]; then
  mkdir -p "$HOME/.claude/commands"
  find "$HOME/.claude/commands" -maxdepth 1 -type l ! -exec test -e {} \; -delete 2>/dev/null
  for c in "$WS"/commands/claude/*.md; do
    ln -sfn "$c" "$HOME/.claude/commands/$(basename "$c")"
  done
fi

# --- Kimi Code ---
# Même format SKILL.md → lien direct vers la source partagée.
KIMI_HOME="${KIMI_CODE_HOME:-$HOME/.kimi-code}"
mkdir -p "$KIMI_HOME"
# skills per-skill (source thémée en sous-dossiers → CLI à plat). Retirer
# l'ancien symlink-dossier d'abord, sinon link_skills_into écrirait DANS la source.
[ -L "$KIMI_HOME/skills" ] && rm -f "$KIMI_HOME/skills"
link_skills_into "$KIMI_HOME/skills"
# Config agent/TUI + instructions globales — même format, liens directs.
# (les tokens OAuth vivent dans $KIMI_HOME/oauth/, hors repo)
for f in config.toml tui.toml AGENTS.md; do
  [ -e "$WS/config/kimi/$f" ] && ln -sfn "$WS/config/kimi/$f" "$KIMI_HOME/$f"
done
# MCP : source canonique unique (config/mcp/servers.json), lien direct.
ln -sfn "$WS/config/mcp/servers.json" "$KIMI_HOME/mcp.json"

# --- MCP partagé (qmd + supabase) : Claude + Antigravity ---
# Claude : user scope = ~/.claude.json, fichier d'état (sessions, oauth)
#          → merge jq, pas de lien. ⚠️ Lancer install.sh Claude fermé :
#          un Claude ouvert réécrit ~/.claude.json en sortant et écraserait le merge.
if [ -f "$HOME/.claude.json" ] && command -v jq >/dev/null 2>&1; then
  _tmp=$(mktemp)
  jq -s '.[0] * .[1]' "$HOME/.claude.json" "$WS/config/mcp/servers.json" > "$_tmp" \
    && mv "$_tmp" "$HOME/.claude.json"
fi
# Antigravity : fichier MCP dédié (~/.gemini/config/mcp_config.json) → lien direct.
mkdir -p "$HOME/.gemini/config"
ln -sfn "$WS/config/mcp/servers.json" "$HOME/.gemini/config/mcp_config.json"

# --- Antigravity (CLI Google, sur abonnement) : skills GLOBAUX ---
# ~/.gemini/config/skills = seul chemin reconnu par les 3 flavours Antigravity
#                           (AGY, AGY CLI, AGY IDE — tests empiriques, juil. 2026)
# Gemini CLI n'est PAS configuré ici : il passe par API payante, inutilisé.
# (son user scope serait ~/.gemini/skills, son hook RTK via config/gemini/hooks.json
#  — retirés le 2026-08-07, récupérables dans l'historique git si besoin)
link_skills_into "$HOME/.gemini/config/skills"
# Règles globales Antigravity = ~/.gemini/GEMINI.md (lu par les 3 flavours).
# Lien direct vers la charte usine (cycle dev par défaut).
ln -sfn "$WS/USINE.md" "$HOME/.gemini/GEMINI.md"

echo "[ai-workspace] symlinks en place. Redémarrer les CLIs pour prise en compte."
