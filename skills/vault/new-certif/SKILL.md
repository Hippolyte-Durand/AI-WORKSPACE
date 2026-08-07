---
name: new-certif
description: Crée une certif (dossier + cockpit + brief + 5 memory + labs/)
disable-model-invocation: true
---

Crée une certif nommée : $ARGUMENTS

## Inputs
| Fichier | Couche | Sections | Pourquoi |
|---|---|---|---|
| `_TEMPLATES/{certif,memory-*,lab}.md` | L3 | tout | structure certif + memory + lab |
| `DOCTRINE.md` | L3 | `#memory`, `#foyer-unique`, `#view-mocs` | routage memory + placement (certifs à plat) + règles UX views |
| `$ARGUMENTS` + réponses champs | L4 | — | nom/acronyme/date_exam |

1. Slug = nom en kebab-case. **Acronyme** = initiales en majuscules (ex : aws-saa → AWSSAA), stocké dans `acronyme` (jamais en préfixe de fichier memory).
2. `DATA/1-Projects/<slug>/<slug>.md` (**cockpit nommé par la certif**, certifs à plat dans 1-Projects) depuis `_TEMPLATES/certif.md` : `type: certif`, `area: Certifs`, `acronyme: <ACRO>`, `statut: en cours`, `créé: <date>`, `date_exam:` (si connue). Les embeds `this.asLink()` marchent tels quels.
3. `memory/{brief,decisions,apprentissages,blocages,sessions,evals}.md` (**sans préfixe**) depuis `_TEMPLATES/memory-*.md` : remplir la FK `projets: ["[[<slug>]]"]` (**`projet` = la certif** — même machinerie que projet), `acronyme: <ACRO>`, `maj: <date>`. `evals` = scores d'exam blanc, `apprentissages` = révisions.
4. **Pas de scaffold vide.** `labs/` naît au premier lab écrit (mkdir juste-à-temps). Un lab = `_TEMPLATES/lab.md` → `labs/<slug>-lab-NN-<titre>.md`, FK `projets: ["[[<slug>]]"]`, `statut`, `maj`. Savoir réutilisable (`concept`/`outil`/…) → `3-Resources/KB/` avec `related: - "[[<slug>]]"`, pas de `doc/` sous la certif.
5. `HOME.md` liste les certifs automatiquement via `Projets.base` (filtre `type == "certif"`) — rien à câbler à la main (`#type-foyer-base` : la base compile depuis le `type`, pas le chemin). Vérifie `python3 _APP/check-vault-integrity.py`. Confirme chemin + acronyme.
