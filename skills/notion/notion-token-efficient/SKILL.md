---
name: notion-token-efficient
description: Discipline token-efficient pour toute opération Notion (créer/éditer une page, requêter une DB, lire) — appliquer AVANT d'appeler un outil Notion, tous CLIs
---

## Mission
Imposer le chemin le moins coûteux en tokens sur chaque opération Notion. À charger avant tout appel d'outil Notion. Sans ça : blocs JSON construits à la main (3-5× le coût du markdown), `notion-fetch` qui dump tout le schéma DB (~4-5K tok), `SELECT *` qui ramène des colonnes relation inutiles.

## Inputs
| Fichier | Couche | Sections | Pourquoi |
|---------|--------|----------|----------|
| `notion://docs/enhanced-markdown-spec` | L3 | tout | syntaxe markdown natif d'écriture — lire 1× seulement si doute sur le format |

## Process
1. **Écrire (créer/éditer)** → `mcp__notion__notion-create-pages` / `mcp__notion__notion-update-page` en **enhanced markdown**. JAMAIS `mcp__notion-cli__API-post-page` avec un tableau `children` de blocs JSON (levier n°1, ÷3-5 sur l'écriture).
2. **Batch** → tout le contenu en UN seul appel d'écriture. Jamais create-puis-append.
3. **Découvrir une DB** → `notion-fetch` sur la database UNE fois. Garder le `collection://…` (data_source_url) et le réutiliser. Ne pas re-fetch pour relire des lignes.
4. **Lire des lignes** → `mcp__notion__notion-query-data-sources` en SQL : `SELECT` colonnes utiles + `WHERE`/`LIMIT`. Pas de `SELECT *` ; pas les colonnes relation (`Parent`/`Enfants`/`Bloque`…) sauf besoin explicite — elles reviennent en JSON arrays d'URLs verbeux.
5. **Lire une page** → `mcp__notion-cli__API-retrieve-page-markdown` (compact), pas le JSON de blocs.

## Outputs
Page(s) Notion créées/éditées via l'outil markdown-natif. Pas d'écriture vault → pas de `check-vault-integrity.py` requis. Contrôle : le payload d'écriture est du markdown, pas des blocs JSON ; toute relecture DB passe par SQL projeté, pas `fetch`.
