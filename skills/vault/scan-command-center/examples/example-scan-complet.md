# Exemple — run scan complet (premier run / pas de last_scanned_commit)

## Situation
`CODEMAP.md` absent ou `last_scanned_commit` manquant.

## Séquence
1. Lire GRAPH_REPORT.md → identifier god nodes (CommandCenterView, frontmatterOf, loadDashboardData), communautés (core / cards / infra / contacts…).
2. `ls src/ src/cards/` → liste exhaustive des .ts.
3. Lire chaque fichier (core d'abord : main.ts, data.ts, store.ts, util.ts, skillsData.ts → puis cards/ par ordre alpha).
4. Rédiger `## Vue d'ensemble` : 1 paragraphe, flux de données (main → store → data → cards), onglets, pattern UI.
5. Rédiger 1 section `### src/...` par fichier (voir `example-section-fichier.md`).
6. Écrire `## Log des modifications` avec la ligne initiale.
7. Insérer `<!-- last_scanned_commit: <HEAD hash> -->` en toute première ligne.

## Vue d'ensemble — exemple de sortie

```markdown
Plugin Obsidian dashboard centralisé : vue monolithique (CommandCenterView) qui agrège vault data (SGBD-md layer) + JSON stores (action queue, mails), trie par type/statut/area, render 9 onglets (dashboard/projets/tickets/contacts/sources/wiki/infra/skills/insights). Flux : main.ts (plugin entry + TabView) → store.ts (data boundary + mutations) → data.ts (indexed pass + pure getters) → cards/*.ts (pure render). UI via Obsidian DOM API.
```

## Log — exemple ligne initiale

```markdown
| 2026-07-23 | a1ff021 | scan initial complet | src/ (5 core) + src/cards/ (17 card renderers) + data.selfcheck indexés (23 fichiers .ts) |
```
