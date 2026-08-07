---
name: scan-command-center
description: Scan incrémental du plugin hippo-command-center — met à jour CODEMAP.md (carte code + log modifs) en ne relisant que les fichiers changés depuis le dernier commit scanné
disable-model-invocation: true
---

# Scan Command Center

> Contrat L2 (modèle ICM, voir `GOUVERNANCE.md#contrat-agent`). Budget cible : 2–8K tokens. Lire ce fichier **en entier** avant d'agir — les règles de format dans `anti-patterns.md` sont non-optionnelles.

## Mission
Maintenir `.obsidian/plugins/hippo-command-center/CODEMAP.md` : carte du code (rôle/exports/dépendances par fichier) + table de log des modifications. Scan **incrémental** : ne relit que les fichiers changés depuis `last_scanned_commit`. Les sessions IA lisent CODEMAP.md au lieu des sources (~4k lignes TS économisées).

## Inputs
| Fichier | Couche | Sections | Pourquoi |
|---|---|---|---|
| `.obsidian/plugins/hippo-command-center/CODEMAP.md` | L4 | commentaire `last_scanned_commit` + table log | point de départ incrémental |
| `anti-patterns.md` (ce dossier) | L3 | tout | règles de format + pièges connus — internaliser avant d'écrire |
| `examples/` (ce dossier) | L3 | tout | référence format attendu par section |
| `output/CODEMAP-template.md` (ce dossier) | L3 | tout | structure cible CODEMAP.md |
| `git diff --name-only <hash>..HEAD -- .obsidian/plugins/hippo-command-center/src` | L4 | — | delta fichiers |
| `.obsidian/plugins/hippo-command-center/graphify-out/GRAPH_REPORT.md` | L4 | tout | structure/communautés — jamais graph.json direct |
| QMD | L4 | — | recherche ciblée si contexte manque |
| fichiers TS **modifiés uniquement** | L4 | — | résumé par fichier |

## Process
1. **Initialisation** : lire `CODEMAP.md` → extraire `last_scanned_commit`. Absent → scan complet (étape 3b).
2. **Delta** : `git log -1 --format=%h -- .obsidian/plugins/hippo-command-center` puis `git diff --name-only <old>..HEAD -- .obsidian/plugins/hippo-command-center/src`. **Zéro delta → "CODEMAP à jour (commit <hash>)", stop, zéro écriture.**
3. **Scan graphify** : `/graphify` sur le plugin (incrémental), lire GRAPH_REPORT.md — god nodes, communautés.
   - **3b (scan complet)** : lire aussi `examples/example-scan-complet.md` avant d'écrire.
4. **Résumés fichiers** : lire chaque fichier modifié → rédiger résumé selon `examples/example-section-fichier.md` (densité, format, interdit).
5. **Mise à jour CODEMAP.md** :
   - Mettre à jour sections `### src/...` existantes, créer si nouveau fichier, **supprimer si fichier disparu**.
   - Si refonte architecture (god node changé, nouvelle communauté) → mettre à jour `## Vue d'ensemble`.
   - Prépendre 1 ligne à `## Log des modifications` : `| YYYY-MM-DD | <hash> | fichier1, fichier2 | résumé 1 ligne |`.
   - Mettre à jour `last_scanned_commit` = hash HEAD.
6. **Validation** : `python3 _APP/check-vault-integrity.py` → 0 erreur obligatoire avant de conclure.

## Outputs
- `CODEMAP.md` mis à jour (à côté du code, hors DATA/, sans frontmatter type).
- 1 ligne log par run.
- Rapport conversation : `[SCAN] <hash> | <N> fichiers delta | <durée> | OK / AVERTISSEMENT`.

## Escalade
- Lecture seule sur `src/`. Ne pas modifier le code plugin.
- Refonte massive (>30% des fichiers renommés) → signaler à Hippo avant de réécrire la carte.
- Ambiguïté sur le rôle d'un fichier → QMD d'abord, puis lire le fichier, jamais inventer.
