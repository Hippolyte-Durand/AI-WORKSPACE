---
name: supabase-token-efficient
description: Discipline token-efficient pour toute opération Supabase MCP (lister, lire, écrire SQL) — appliquer AVANT d'appeler un outil Supabase, tous CLIs
---

## Mission
Imposer le chemin le moins coûteux en tokens sur chaque appel Supabase. À charger avant tout outil `mcp__supabase__*`. Sans ça : `list_tables verbose` dump ~75K tokens d'un coup, `SELECT *` ramène des colonnes `jsonb` massives (`content`), chaque retour réinjecté gonfle le cache-read à chaque tour suivant.

## Process
0. **RPC-first (si le projet en expose)** → une RPC taillée bat le SQL brut : moins de tokens, pas d'échappement de quotes, payload épuré (`jsonb_strip_nulls`). Ex. nexa-cloud : lire le kanban = `select get_agent_kanban_context()`, jamais requêter `project_tasks` à la main. Ne PAS inventer de RPC — utiliser seulement celles listées dans le CLAUDE.md du repo. Le SQL brut ci-dessous ne vaut que pour les chemins sans RPC.
1. **Découvrir le schéma** → Si le projet expose `get_schema()`, appeler en premier : `select get_schema()` — retourne tables + colonnes en un seul appel, ~50x moins de tokens que `list_tables verbose`. Créer cette fonction si absente (voir §Fonction get_schema). Sinon : `execute_sql` sur `information_schema.tables` filtré : `select table_name from information_schema.tables where table_schema='public' and table_name ilike '%x%'`.
2. **Découvrir des colonnes** → `information_schema.columns` filtré sur les tables voulues (`table_name in (...)`), pas la table entière du schéma.
3. **Lire des lignes** → `SELECT` colonnes utiles + `WHERE` + `LIMIT` toujours. Jamais `SELECT *`.
4. **Colonnes `jsonb` / gros texte** (`content`, `filters`, `sort`…) → ne pas les ramener sauf besoin explicite. Préférer `content_text`, `name`, `updated_at`. Le `content` blocs-éditeur pèse des milliers de tokens par ligne.
5. **Écrire** → `INSERT ... RETURNING` seulement les champs utiles (pas `RETURNING *`). Batch en un seul appel.
6. **DDL** (create/alter) → `apply_migration`, pas `execute_sql`.
7. **Debug** → `get_advisors` / `query_logs` avant de tâtonner en SQL.

## Fonction get_schema

À déployer une fois par projet via `apply_migration` :

```sql
CREATE OR REPLACE FUNCTION get_schema()
RETURNS jsonb AS $$
SELECT jsonb_agg(jsonb_build_object(
  'table', table_name,
  'columns', (
    SELECT jsonb_agg(jsonb_build_object(
      'name', column_name,
      'type', data_type,
      'nullable', is_nullable
    ))
    FROM information_schema.columns c
    WHERE c.table_name = t.table_name
    AND c.table_schema = 'public'
  )
))
FROM information_schema.tables t
WHERE table_schema = 'public'
AND table_type = 'BASE TABLE';
$$ LANGUAGE sql STABLE;
```

Appel : `SELECT get_schema();` — 1 outil call au lieu de 10+. Mentionner dans `CLAUDE.md` du projet : `"Schéma DB : SELECT get_schema() via Supabase MCP."`.

## Outputs
Requêtes projetées et bornées. Contrôle : aucun `list_tables`, aucun `SELECT *`, tout `jsonb` lourd exclu sauf demande, tout écrit via `RETURNING` ciblé.
