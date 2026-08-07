---
name: capture
description: Capture fin de session — ajoute les sections datées dans les 6 fichiers memory
disable-model-invocation: true
---

Capture de session pour le projet (ou feature) : $ARGUMENTS
Format accepté : `<projet-slug>` ou `<projet-slug> <N-feature-slug>`
(si vide → lire `_STATE.md` frontmatter : `projet_actif:` + `feature_active:` pour déduire la cible, puis confirmer avec la conversation courante)

## Inputs
| Fichier | Couche | Sections | Pourquoi |
|---|---|---|---|
| `DOCTRINE.md` | L3 | `#memory`, `#compaction` | routage fichiers + seuil rollup 10KB |
| `<projet>/memory/*.md` ou `features/<N>/memory/*.md` | L4 | tout | état actuel à compléter |
| conversation courante | L4 | — | source des sections datées |
| `_STATE.md` | L4 | tout | à mettre à jour après capture |

## Routage feature vs projet

**Détection** : si `$ARGUMENTS` contient un slug feature (pattern `\d{2}-\w+`) OU si la conversation porte clairement sur une feature précise → **mode feature**. Sinon → **mode projet**.

### Mode feature (`<projet> <N-feature-slug>`)
Écrire dans `DATA/1-Projects/<area>/<projet>/features/<N-slug>/memory/` :
1. **sessions.md** — Fait / Suite (obligatoire)
2. **decisions.md** — choix structurants propres à la feature
3. **blocages.md** — Symptôme / Résolution ; `statut` ouvert|résolu
> `apprentissages.md` et `evals.md` restent niveau **projet** (jamais dans feature memory).

### Mode projet (`<projet>`)
Écrire dans `DATA/1-Projects/<area>/<projet>/memory/` :
1. **sessions.md** — section : Fait / Suite.
2. **decisions.md** — par choix structurant : Choix / Pourquoi / Rejeté.
3. **apprentissages.md** — Appris / Change. Si utile hors projet → aussi note KB typée dans `DATA/3-Resources/KB/`, ajouter le lien dans `kb:`.
4. **blocages.md** — Symptôme / Résolution ; `statut` ouvert|résolu.
5. **evals.md** — Note /5, Bien, Raté, Règle.

**Dans les deux modes** : date = aujourd'hui, section `### YYYY-MM-DD — <titre>` en haut du corps, bump `maj:` frontmatter. **Ne crée pas de nouveaux fichiers.**

## Routage client-memory (si le projet a un `client:`)
Avant d'écrire, trie chaque item avec le **test unique** : « ça reste utile après la fin de CE projet, pour les PROCHAINS projets de ce client ? »
- **OUI → `DATA/3-Resources/Clients/<client>/memory/`** (durable, relation) : standard du compte (decisions), piège récurrent du client (apprentissages), problème chronique de l'infra client (blocages), contrainte/interlocuteur permanent (brief), touche compte HORS projet — support/commercial/incident isolé (sessions).
- **NON → projet-memory** (défaut) : tout ce qui est propre à l'exécution de ce projet. Une séance de travail SUR le projet va toujours dans les sessions du **projet**.
- Client-memory = **5 fichiers** (pas d'`evals`). Même format section `### YYYY-MM-DD — <titre>`, FK `client:` au lieu de `projet:`, bump `maj:`.
- Pas de client → ignore ce bloc.

Règles : pourquoi avant quoi, concis, n'invente rien hors de la session. FK = propriété nommée (`projet`/`client`/`kb`), `related` = liens KB↔KB.

## _STATE.md (après capture)
Mets à jour `_STATE.md` à la racine du vault :
- **Phase actuelle** : résumé 1 ligne de l'état du projet/vault
- **Prochaines actions** : 3 items max, numérotés, actionnables
- **Fait aujourd'hui** : bullet list des actions majeures de la session
- **Blocages immédiats** : ce qui bloque (ou "Aucun")
- Bump `maj:` dans le frontmatter.

## Validation (après capture)
Lance **dans cet ordre** :
1. `python3 _APP/check-vault-integrity.py` — validation intégrité (pluriels, quotes, FM). **DOIT passer.**
2. Si des erreurs → STOP capture, affiche erreurs, demande fix.

## Compaction (après validation OK)
Lance `python3 _APP/check-vault-integrity.py` (again). Si un warning `memory XKB > 10KB — rollup requis` concerne un fichier que tu viens de toucher : exécute le rollup selon `DOCTRINE.md#compaction` (sections anciennes/annulées → 1 ligne condensée, détail verbatim → `memory/archive/<fichier>-YYYY-MM.md`, liens en path complet). Puis relance le check.
