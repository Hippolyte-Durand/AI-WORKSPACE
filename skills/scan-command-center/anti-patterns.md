# Anti-patterns — scan-command-center

## Format des résumés de fichier

❌ **Trop vague / prose marketing**
```
### src/data.ts
Ce fichier gère les données du vault. Il est important pour le plugin.
```

❌ **Trop long / répète ce que le nom dit**
```
### src/data.ts
Ce fichier s'appelle data.ts. Il contient des données. Il a des fonctions qui font des choses avec les données du vault Obsidian.
```

✅ **Dense, factuel, exports + dépendances + pattern**
```
### src/data.ts
Vault data layer (SGBD-md) : buildVaultIndex() parcourt vault une seule fois → byType + bySlug. 9 getters purs (prennent VaultIndex, ne re-scan pas). Rows typées (ProjectRow, TicketRow, …). Exclusions : templates + archive. Pas d'I/O.
```

---

## Règle densité : 1–4 lignes MAX par fichier
- 1 ligne : fichier utilitaire simple (util.ts, components.ts)
- 2–3 lignes : fichier de logique (data.ts, store.ts, kanban.ts)
- 4 lignes MAX : fichier complexe avec plusieurs responsabilités (main.ts, projectDetail.ts)
- Jamais de phrase "ce fichier fait X" → nommer directement le pattern (SGBD-md layer, pure render, data boundary, etc.)

---

## Graphify : ne jamais lire graph.json
`graph.json` = 121KB → context overflow garanti. Toujours `GRAPH_REPORT.md` (4.6KB).

---

## Delta git : ne pas scanner ce qui n'a pas changé
Si `git diff --name-only <old>..HEAD` retourne 3 fichiers → lire SEULEMENT ces 3 fichiers.
Ne pas "vérifier" les autres par précaution → ponytail, zéro scan spéculatif.

---

## Vue d'ensemble : ne mettre à jour que si architecture change
Flux `main.ts → store → data → cards` est stable. Ne pas réécrire la vue d'ensemble à chaque run.
Trigger de mise à jour : nouveau tab, god node changé, flux de données modifié.

---

## Log des modifications : 1 ligne, résumé utile
❌ `| 2026-07-23 | abc1234 | src/data.ts | modification |`
✅ `| 2026-07-23 | abc1234 | src/data.ts | ajout getter getProjectDetail reconstruit 1 projet complet |`

---

## Ne pas inventer les exports/types
Si un fichier exporte `FuzzySuggestModal` → écrire `FuzzySuggestModal`, pas "une modal". Noms exacts depuis le source.
