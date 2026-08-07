---
name: new-feature
description: Crée une feature dans un projet existant — dossier + cockpit feature + 4 fichiers memory (brief, decisions, sessions, blocages)
disable-model-invocation: true
---

Projet + feature : $ARGUMENTS
(format attendu : `<projet-slug> <N-feature-slug>` ex: `agentics-obsidian-os 01-core-dashboard`)

## Mission
Instancier une nouvelle feature dans un projet vault : dossier `features/<N-slug>/`, cockpit feature, 4 fichiers memory. Mettre à jour le cockpit projet (section Features).

## Inputs
| Fichier | Couche | Sections | Pourquoi |
|---|---|---|---|
| `_TEMPLATES/feature.md` | L3 | tout | structure cockpit feature |
| `SCHEMA.md#feature` | L3 | type feature | champs + FK obligatoires |
| `DATA/1-Projects/<area>/<projet>/<projet>.md` | L4 | section Features | base query auto-alimente, vérifier `features:` FM projet |
| `_STATE.md` | L4 | frontmatter | à mettre à jour après création |

## Process
1. Parser `$ARGUMENTS` → `<projet-slug>` + `<N-feature-slug>`. Si manquant → escalade.
2. Localiser le projet : `find DATA/1-Projects -type d -name "<projet-slug>"`.
3. Créer `features/<N-feature-slug>/` dans le dossier projet.
4. Créer `features/<N-feature-slug>/<N-feature-slug>.md` depuis `_TEMPLATES/feature.md`. Remplacer `<projet>`, `<feature-slug>`, `<date>`, `<N-nom>`. Laisser `briefs:/decisions:/sessions:/blocages:` **vides** (remplis par `sync-memory-downlinks.py` en fin, step 8). Remplir `branche:` avec `"feature/<N-feature-slug>"`.
5. Créer `features/<N-feature-slug>/memory/brief.md` :
   ```yaml
   ---
   type: brief
   features:
     - "[[<N-feature-slug>]]"
   maj: <date>
   ---
   # 📋 Brief — <Feature Name>
   ⬆️ [[<projet-slug>]] > [[<N-feature-slug>]]
   **🧭 Contexte** :  **🎯 Objectif** :  **🗺️ Périmètre** :  **📦 Livrables** :  **🚧 Contraintes** :  **✅ Critères de succès** :
   ```
   **FK feature memory = `features:` SEUL** (jamais `projets:` — sinon pollution `projet.decisions` ← feature ; le lien au projet est transitif via `feature.projets` du cockpit). Le routing vertical (feature→projet→client) est chargé par `/load-feature`, pas via un FK direct de la memory.
6. Créer `memory/decisions.md`, `memory/sessions.md`, `memory/blocages.md` (même pattern FK `features:` array, PAS de `projets:`).
7. Mettre à jour `_STATE.md` frontmatter : écrire `projet_actif: "[[<projet>]]"` et `feature_active: "[[<N-feature-slug>]]"`.
8. `python3 _APP/sync-memory-downlinks.py` → remplit les down-links du cockpit feature.
9. `python3 _APP/check-vault-integrity.py` → 0 erreur.

## Outputs
- `features/<N-feature-slug>/<N-feature-slug>.md`
- `features/<N-feature-slug>/memory/{brief,decisions,sessions,blocages}.md`
- Cockpit projet mis à jour (section Features)
- Intégrité vault OK

## Escalade
- Projet introuvable → demander l'area ou chemin exact.
- `$ARGUMENTS` manque le numéro de feature (format `N-slug`) → demander.
