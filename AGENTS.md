# AGENTS.md — conventions anti vendor-lock (globales, réutilisables)

Conventions de portabilité partagées par **tous les projets** (vault Obsidian, repos de code) et **tous les CLIs** (Claude Code, Kimi, Antigravity). But : rien de verrouillé à un provider. Les règles *spécifiques* à un projet vivent dans le projet (ex : le vault a `_agent-core.md`).

**Source unique** : `~/ai-workspace` (repo git) = vérité. Distribué aux CLIs par **symlinks** (jamais de copies) : par skill, et fichier par fichier pour la config.

**Skills** : format ouvert **Agent Skills `SKILL.md`** (corps portable Claude/Kimi/Antigravity). 6 champs du spec : `name`, `description`, `license`, `compatibility`, `metadata`, `allowed-tools`. `allowed-tools` = appliqué par Claude Code seulement (inerte ailleurs, sans danger).

**Instructions** : fichier **`AGENTS.md`** (standard neutre). Claude lit `CLAUDE.md` → l'importer via `@AGENTS.md`. Jamais de doctrine dans un format proprio.

**Tools** : scripts portables (`.py`) dans `tools/`, appelés par **chemin absolu** — pas verrouillés à un CLI. MCP seulement pour un vrai tool typé cross-session (sinon YAGNI).

**MCP** : config canonique unique (`ai-workspace/config/mcp/servers.json`), répliquée par CLI.

**Auth** : CLIs sur **abonnement** (Claude Code, Kimi, Antigravity), zéro clé API → pas de lock-in facturation.

**Frontière** : instructions + skills + tools = partagés/portables. Plomberie par CLI (`settings.json` permissions/hooks) = spécifique, une fois par outil.
