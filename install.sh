#!/usr/bin/env sh
# ai-workspace — bootstrap des symlinks sur machine neuve (idempotent).
# Source unique = ce repo. Les CLIs ne reçoivent que des liens, jamais de copies.
# Usage : sh install.sh
set -e
WS="$(cd "$(dirname "$0")" && pwd)"

# Rend un template .tpl en substituant __WS__ par le chemin absolu du clone
# (les @imports doivent être absolus : pas de ~/ universel Claude/Kimi/AGY).
# Sortie dans $WS/.rendered/ (gitignoré) → portable sur toute machine/user.
RENDERED="$WS/.rendered"
mkdir -p "$RENDERED"
render() {  # render <tpl> <basename-sortie> ; echo le chemin rendu
  out="$RENDERED/$2"
  sed "s|__WS__|$WS|g" "$1" > "$out"
  echo "$out"
}

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
for x in settings.json RTK.md hooks agents agents-drafts; do
  [ -e "$WS/config/claude/$x" ] && ln -sfn "$WS/config/claude/$x" "$HOME/.claude/$x"
done
# CLAUDE.md : rendu depuis .tpl (imports absolus portables), puis symlink.
ln -sfn "$(render "$WS/config/claude/CLAUDE.md.tpl" CLAUDE.md)" "$HOME/.claude/CLAUDE.md"
# Claude injecte du .system/ dans ~/.claude/skills → liens par skill.
link_skills_into "$HOME/.claude/skills"
# Purge les commands du cycle (retirées : l'orchestration vit désormais dans les
# skills, invoqués par /nom à l'identique sur les 3 CLIs). Ne touche que nos
# liens morts, pas d'éventuelles commands perso encore valides.
[ -d "$HOME/.claude/commands" ] && \
  find "$HOME/.claude/commands" -maxdepth 1 -type l ! -exec test -e {} \; -delete 2>/dev/null

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
for f in config.toml tui.toml; do
  [ -e "$WS/config/kimi/$f" ] && ln -sfn "$WS/config/kimi/$f" "$KIMI_HOME/$f"
done
# AGENTS.md : rendu depuis .tpl (imports absolus portables), puis symlink.
ln -sfn "$(render "$WS/config/kimi/AGENTS.md.tpl" kimi-AGENTS.md)" "$KIMI_HOME/AGENTS.md"
# MCP : source canonique unique (config/mcp/servers.json), lien direct.
ln -sfn "$WS/config/mcp/servers.json" "$KIMI_HOME/mcp.json"

# --- MCP partagé : Claude + Antigravity ---
# Claude : user scope = ~/.claude.json, fichier d'état (sessions, oauth) non
#   symlinkable → on REMPLACE la clé mcpServers par celle du repo (autoritaire :
#   ajoute ET retire, pas de serveur fantôme). Tout le reste de l'état est
#   préservé. Source unique = config/mcp/servers.json, zéro drift.
#   ⚠️ Lancer install.sh Claude fermé : un Claude ouvert réécrit ~/.claude.json
#   en sortant et écraserait la sync.
if [ -f "$HOME/.claude.json" ] && command -v jq >/dev/null 2>&1; then
  _tmp=$(mktemp)
  jq --slurpfile s "$WS/config/mcp/servers.json" \
    '.mcpServers = $s[0].mcpServers' "$HOME/.claude.json" > "$_tmp" \
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
# Stub qui importe AGENTS.md (anti-lock) + USINE.md (cycle dev) — mêmes
# doctrines que Claude/Kimi. Rendu depuis .tpl (imports absolus portables).
ln -sfn "$(render "$WS/config/gemini/GEMINI.md.tpl" GEMINI.md)" "$HOME/.gemini/GEMINI.md"

echo "[ai-workspace] symlinks en place. Redémarrer les CLIs pour prise en compte."
