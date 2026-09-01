#!/usr/bin/env sh
# ai-workspace — bootstrap des symlinks sur machine neuve (idempotent).
# Source unique = ce repo. Les CLIs ne reçoivent que des liens, jamais de copies.
# Usage : sh install.sh [profil]      (profil par defaut : celui du dernier run,
#                                      sinon "default")
# Un profil (profiles/<nom>.conf) decide QUELS skills sont exposes aux CLIs, et
# (profiles/<nom>.md) quelle doctrine metier s'ajoute aux instructions globales.
# Le repo reste la source unique complete : un profil filtre, il ne supprime rien.
set -e
WS="$(cd "$(dirname "$0")" && pwd)"

# Profil : argument > dernier profil installe > default. Memorise, pour qu'un
# rerun (apres un pull) n'ait pas besoin de le repreciser.
PROFILE_STATE="$WS/.rendered/.profile"
if [ -n "$1" ]; then PROFILE="$1"
elif [ -f "$PROFILE_STATE" ]; then PROFILE="$(cat "$PROFILE_STATE")"
else PROFILE=default; fi
PROFILE_CONF="$WS/profiles/$PROFILE.conf"
if [ ! -f "$PROFILE_CONF" ]; then
  echo "[install] profil inconnu : $PROFILE"
  echo "[install] disponibles : $(ls "$WS"/profiles/*.conf 2>/dev/null | while read -r c; do basename "$c" .conf; done | tr '
' ' ')"
  exit 1
fi

# Rend un template .tpl en substituant __WS__ par le chemin absolu du clone
# (les @imports doivent être absolus : pas de ~/ universel Claude/Kimi/AGY).
# Sortie dans $WS/.rendered/ (gitignoré) → portable sur toute machine/user.
RENDERED="$WS/.rendered"
mkdir -p "$RENDERED"

# Sous Git Bash, ln -s COPIE au lieu de lier (defaut MSYS) : drift silencieux.
# nativestrict force l'echec plutot que la copie -> on detecte et on replie.
export MSYS=winsymlinks:nativestrict

# Capacite symlink testee UNE fois (Windows sans Mode Developpeur : refusee).
if ln -sfn "$WS" "$RENDERED/.probe" 2>/dev/null; then NATIVE_LINKS=1; else NATIVE_LINKS=0; fi
rm -f "$RENDERED/.probe"
# File d'attente du repli : un seul powershell en fin de script (un process par
# lien coutait ~3 min pour ~110 liens).
PSQ="$RENDERED/links.ps1"
: > "$PSQ"

# link <source> <cible> — remplace ln -sfn partout.
# Symlink natif si permis. Sinon (Windows sans Mode Dev ni admin) : jonction
# pour un dossier, lien dur pour un fichier — les deux sans privilege, et vus
# comme la source par tous les CLIs.
# /!\ lien dur : un git checkout/pull qui REMPLACE le fichier source casse le
# lien (la cible garde l'ancien contenu) -> relancer install.sh apres un pull.
# Activer le Mode Developpeur Windows supprime ce repli et son bemol.
link() {
  rm -rf "${2:?}"
  if [ "$NATIVE_LINKS" = 1 ]; then ln -sfn "$1" "$2"; return; fi
  if [ -d "$1" ]; then _t=Junction; else _t=HardLink; fi
  printf "New-Item -ItemType %s -Path '%s' -Target '%s' -Force > \$null\n" \
    "$_t" "$(cygpath -w "$2")" "$(cygpath -w "$1")" >> "$PSQ"
}

# Vide la file du repli Windows (no-op si symlinks natifs).
flush_links() {
  [ -s "$PSQ" ] || return 0
  powershell -NoProfile -ExecutionPolicy Bypass -File "$PSQ"
}

render() {  # render <tpl> <basename-sortie> ; echo le chemin rendu
  out="$RENDERED/$2"
  sed -e "s|__WS__|$WS|g" -e "s|__PROFILE__|$PROFILE|g" "$1" > "$out"
  echo "$out"
}

# Selection des skills du profil -> $RENDERED/skills.list (un chemin par ligne).
# Motifs (relatifs a skills/) : "*" = tout, "theme/" = le theme entier,
# "theme/skill" = un skill precis. Commentaires "#" et lignes vides ignores.
SKILLS_LIST="$RENDERED/skills.list"
build_skills_list() {
  : > "$SKILLS_LIST"
  # motifs nettoyes UNE fois (sinon le .conf serait relu pour chaque skill)
  _pats="$RENDERED/.profile-patterns"
  sed -e 's/#.*//' -e 's/[[:space:]]*$//' -e '/^$/d' "$PROFILE_CONF" > "$_pats"
  find "$WS/skills" -name SKILL.md | while read -r f; do
    s="$(dirname "$f")"
    rel="${s#"$WS"/skills/}"
    while read -r pat; do
      case "$pat" in
        '*')  echo "$s" >> "$SKILLS_LIST"; break ;;
        */)   case "$rel" in "$pat"*) echo "$s" >> "$SKILLS_LIST"; break ;; esac ;;
        *)    if [ "$rel" = "$pat" ]; then echo "$s" >> "$SKILLS_LIST"; break; fi ;;
      esac
    done < "$_pats"
  done
  echo "[install] profil $PROFILE : $(wc -l < "$SKILLS_LIST" | tr -d ' ') skills exposes sur $(find "$WS/skills" -name SKILL.md | wc -l | tr -d ' ') dans le repo"
}
build_skills_list

# Lie chaque skill de $WS/skills dans $1 (un symlink PAR skill, jamais le dossier
# entier : certains CLIs écrivent du runtime dans leur dossier skills).
# Une vraie copie existante n'est remplacée que si identique à la source.
link_skills_into() {
  mkdir -p "$1"
  # purge les liens morts (skills retirés/déplacés depuis le dernier run)
  find "$1" -maxdepth 1 -type l ! -exec test -e {} \; -delete 2>/dev/null
  # purge les liens vers des skills que le profil courant n'expose plus (sinon
  # un passage phyts -> default -> phyts laisserait des orphelins encore vivants)
  find "$1" -maxdepth 1 -type l | while read -r t; do
    grep -qxF "$(readlink "$t" 2>/dev/null)" "$SKILLS_LIST" 2>/dev/null || rm -f "$t"
  done
  # un skill = un dossier contenant SKILL.md, a n'importe quelle profondeur
  # (source rangee par theme). Le CLI recoit toujours du PLAT.
  while read -r s; do
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
    link "$s" "$t"
  done < "$SKILLS_LIST"
}

# --- Claude Code ---
# Symlinks par FICHIER/dossier de config, jamais ~/.claude entier (runtime :
# sessions, caches, .system/). settings.local.json reste local, hors repo.
mkdir -p "$HOME/.claude"
for x in settings.json RTK.md hooks agents agents-drafts; do
  [ -e "$WS/config/claude/$x" ] && link "$WS/config/claude/$x" "$HOME/.claude/$x"
done
# CLAUDE.md : rendu depuis .tpl (imports absolus portables), puis symlink.
link "$(render "$WS/config/claude/CLAUDE.md.tpl" CLAUDE.md)" "$HOME/.claude/CLAUDE.md"
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
  [ -e "$WS/config/kimi/$f" ] && link "$WS/config/kimi/$f" "$KIMI_HOME/$f"
done
# AGENTS.md : rendu depuis .tpl (imports absolus portables), puis symlink.
link "$(render "$WS/config/kimi/AGENTS.md.tpl" kimi-AGENTS.md)" "$KIMI_HOME/AGENTS.md"
# MCP : source canonique unique (config/mcp/servers.json), lien direct.
link "$WS/config/mcp/servers.json" "$KIMI_HOME/mcp.json"

# --- MCP partagé : Claude + Antigravity ---
# Claude : user scope = ~/.claude.json, fichier d'état (sessions, oauth) non
#   symlinkable → on REMPLACE la clé mcpServers par celle du repo (autoritaire :
#   ajoute ET retire, pas de serveur fantôme). Tout le reste de l'état est
#   préservé. Source unique = config/mcp/servers.json, zéro drift.
#   ⚠️ Lancer install.sh Claude fermé : un Claude ouvert réécrit ~/.claude.json
#   en sortant et écraserait la sync.
if [ -f "$HOME/.claude.json" ]; then
  if command -v jq >/dev/null 2>&1; then
    _tmp=$(mktemp)
    jq --slurpfile s "$WS/config/mcp/servers.json" \
      '.mcpServers = $s[0].mcpServers' "$HOME/.claude.json" > "$_tmp" \
      && mv "$_tmp" "$HOME/.claude.json"
  elif command -v node >/dev/null 2>&1; then
    # jq est rarement present sous Windows : meme transformation en Node.
    node "$WS/bin/mcp-sync.js" "$HOME/.claude.json" "$WS/config/mcp/servers.json"
  else
    echo "[install] ni jq ni node : sync MCP de ~/.claude.json SAUTEE"
  fi
fi
# Antigravity : fichier MCP dédié (~/.gemini/config/mcp_config.json) → lien direct.
mkdir -p "$HOME/.gemini/config"
link "$WS/config/mcp/servers.json" "$HOME/.gemini/config/mcp_config.json"

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
link "$(render "$WS/config/gemini/GEMINI.md.tpl" GEMINI.md)" "$HOME/.gemini/GEMINI.md"

printf '%s' "$PROFILE" > "$PROFILE_STATE"
echo "[ai-workspace] profil $PROFILE en place. Redémarrer les CLIs pour prise en compte."

flush_links
