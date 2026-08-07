---
name: split-module
description: "Audit + split de fichiers trop longs ou à responsabilités mélangées — barrel re-export safe, build gate obligatoire. Invoquer manuellement : audit / plan / exec."
disable-model-invocation: true
---

$ARGUMENTS format : `<mode> [cible]`
- `audit [path]` — rapport fichiers à risque (dossier ou fichier)
- `plan <file>` — proposition de découpage nommé, attendre OK
- `exec <file>` — exécuter le plan approuvé + build gate

Si $ARGUMENTS vide → afficher ce bloc usage et stop.

## Règle fondamentale

> **1 fichier = 1 fonction métier = 1 fonction logique = 1 output.**

Test : "Ce fichier fait quoi ?" doit avoir une réponse en une phrase sans "et".
- ✅ "Charge et transforme les données vault" (1 chose)
- ❌ "Charge les données, render l'UI, et gère les events" (3 choses → 3 fichiers)

Un fichier qui produit deux types d'output différents (ex: données JSON + DOM) viole la règle. Splitter.

## Inputs
| Fichier | Couche | Sections | Pourquoi |
|---|---|---|---|
| `audit.py` (skill-local) | L2 | — | métriques mécaniques : lignes, import_domains, exports, call graph |
| `CODEMAP.md` (si existe) | L3 | Vue d'ensemble + Fichiers | tailles + responsabilités indexées, SST candidates |
| `graphify-out/GRAPH_REPORT.md` (si existe) | L3 | Communautés, God nodes | confirmer SST (très importé + cohérent → ne pas splitter) |
| `<target-file>` | L4 | tout | fichier à analyser ou splitter |
| `package.json` / `tsconfig.json` / `pyproject.toml` | L4 | scripts, compilerOptions | auto-détecter gate de validation |
| `$ARGUMENTS` | L4 | — | mode + chemin cible |

---

## L0 — Routing

Parser $ARGUMENTS → mode + cible. Exécuter le process correspondant.

---

## Mode : audit

**Signal de danger = cohérence interne, pas connectivité externe.**
Un fichier très importé peut être une SST (bonne chose). Le danger = mélange de responsabilités dans le même fichier.

### Process
1. Chercher `CODEMAP.md` et `graphify-out/GRAPH_REPORT.md` dans le répertoire courant → charger si présents (L3 context)
2. Identifier chemin cible : si $ARGUMENTS contient un chemin → l'utiliser ; sinon `src/` si existe, sinon `.`
3. Lancer : `python3 <skill-dir>/audit.py <path>`
4. Afficher tableau trié par score décroissant :

```
Fichier               | Lignes | Domaines import | Score | Flag
src/main.ts           |  580   |       5         | 0.87  | 🔴 danger
src/store.ts          |  310   |       4         | 0.61  | 🟡 warning
src/data.ts           |  420   |       2         | 0.52  | 🟡 warning
src/skillsData.ts     |  140   |       2         | 0.31  | ✅ ok
src/util.ts           |   60   |       1         | 0.08  | ✅ sst (4 imports)
```

5. Sous le tableau : recommandations prioritaires (danger d'abord)
6. Aucune modification. Aucune action.

---

## Mode : plan

### Process
1. Charger contexte L3 (CODEMAP, GRAPH_REPORT si dispo)
2. `python3 <skill-dir>/audit.py <file>` → métriques
3. Lire le fichier source entier
4. Appliquer la règle **1 fichier = 1 fonction métier = 1 output** :
   - Poser la question : "Ce fichier fait quoi ?" → si la réponse contient "et" → split
   - Identifier chaque output distinct (DOM, JSON, side-effect fichier, transformation pure…)
   - Chaque output distinct = un fichier cible séparé
   - Analyser clusters sémantiques internes :
     - Quelles fonctions s'appellent entre elles ? (call graph local)
     - Quels imports servent quel groupe de fonctions ?
     - Quels exports n'ont aucun lien sémantique avec les autres ?
5. Si le fichier est `sst_candidate` ET cohérent → signaler "SST cohérente, split déconseillé" et stop
6. Proposer le découpage :

```
Proposition split — src/main.ts

Nouveau fichier : src/view-layout.ts
  → renderDashboard(), renderProjectsTab(), renderTicketsTab()
  → imports concernés : ./cards/*, obsidian.ItemView

Nouveau fichier : src/event-handlers.ts
  → setupVaultListeners(), debounce(), onMetadataChange()
  → imports concernés : obsidian.Events, ./store

Reste dans main.ts :
  → CommandCenterPlugin (entry), VIEW_TYPE, constantes tabs
  → Re-exports : export { renderDashboard } from "./view-layout"
               export { setupVaultListeners } from "./event-handlers"
```

7. **STOP — attendre confirmation avant exec.**

---

## Mode : exec

**Prérequis : plan approuvé dans la conversation courante.**
Si pas de plan visible → lancer plan d'abord.

### Process
1. Créer chaque nouveau fichier avec le code déplacé (imports ajustés)
2. Dans l'ancien fichier : ajouter les barrel re-exports pour chaque symbole déplacé
   ```typescript
   export { renderDashboard } from "./view-layout";
   export { setupVaultListeners } from "./event-handlers";
   ```
3. Détecter gate de validation :
   - `package.json` a `scripts.build` → `npm run build`
   - `tsconfig.json` présent → `tsc --noEmit`
   - Fichiers `.py` → `python3 -m py_compile <nouveaux-fichiers>`
4. Lancer gate → **DOIT passer**
5. **Si échec** :
   - Afficher erreur exacte
   - Rollback : supprimer nouveaux fichiers, restaurer l'original
   - Stop — diagnostiquer avant de relancer
6. **Si succès** : rapport final

```
✅ Split OK — src/main.ts

Créés :
  src/view-layout.ts      (renderDashboard, renderProjectsTab, renderTicketsTab)
  src/event-handlers.ts   (setupVaultListeners, debounce, onMetadataChange)

Re-exports dans main.ts : 3 symboles (imports existants intacts)
Gate : npm run build ✅

Étape optionnelle : migrer les imports directs vers les nouveaux chemins,
puis supprimer les re-exports de main.ts.
```

---

## Références
- `references/split-patterns.md` — barrel re-export, circular dep, naming
- `references/risk-rubric.md` — seuils scores + exemples concrets
