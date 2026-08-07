#!/usr/bin/env sh
# ai-workspace — bootstrap des symlinks sur machine neuve (idempotent).
# Source unique = ce repo. Les CLIs ne reçoivent que des liens, jamais de copies.
# Usage : sh install.sh
set -e
WS="$(cd "$(dirname "$0")" && pwd)"

# --- Claude Code ---
# Symlinks par FICHIER/dossier de config, jamais ~/.claude entier (runtime :
# sessions, caches, .system/). settings.local.json reste local, hors repo.
mkdir -p "$HOME/.claude/skills"
for x in settings.json CLAUDE.md RTK.md hooks agents agents-drafts; do
  [ -e "$WS/config/claude/$x" ] && ln -sfn "$WS/config/claude/$x" "$HOME/.claude/$x"
done

# Skills : un symlink PAR skill. Claude injecte du .system/ dans
# ~/.claude/skills — si le dossier entier était un lien, ça polluerait le repo.
for s in "$WS"/skills/*/; do
  name="$(basename "$s")"
  target="$HOME/.claude/skills/$name"
  # Remplace une éventuelle copie (vrai dossier) par le lien
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    rm -rf "${target:?}"
  fi
  ln -sfn "${s%/}" "$target"
done

# --- Kimi Code ---
# Même format SKILL.md → lien direct vers la source partagée.
KIMI_HOME="${KIMI_CODE_HOME:-$HOME/.kimi-code}"
mkdir -p "$KIMI_HOME"
ln -sfn "$WS/skills" "$KIMI_HOME/skills"

echo "[ai-workspace] symlinks en place. Redémarrer les CLIs pour prise en compte."
