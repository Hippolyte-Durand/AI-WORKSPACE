---
name: load-feature
description: Charge le contexte complet d'une feature (memory/ feature + brief projet) avant de travailler dessus
---

Projet + feature : $ARGUMENTS
(format : `<projet-slug> <N-feature-slug>` ex: `agentics-obsidian-os 01-core-dashboard`)

## Mission
Donner à l'IA le contexte précis d'une feature avant d'agir : 4 fichiers memory feature + **pile brief verticale** (projet, et client si projet client). Zéro fichier écrit — résumé en conversation puis attente instruction.

## Inputs
| Fichier | Couche | Sections | Pourquoi |
|---|---|---|---|
| `features/<N-slug>/memory/brief.md` | L3 | tout | objectif + contraintes feature — internaliser |
| `features/<N-slug>/memory/decisions.md` | L3 | tout | choix déjà pris sur cette feature |
| `features/<N-slug>/memory/sessions.md` | L4 | 2 entrées top | dernière session feature |
| `features/<N-slug>/memory/blocages.md` | L4 | statut ouvert | ce qui bloque cette feature |
| `<projet>/memory/brief.md` | L3 | tout | contexte projet parent (contraintes ce projet) |
| `Clients/<c>/memory/brief.md` | L3 | tout | **si** brief projet a `clients:` → haut de la pile client→projet→feature (DOCTRINE#memory) |

## Process
1. Parser `$ARGUMENTS` → projet + feature slug. Localiser `features/<N-slug>/`.
2. Lire les 4 fichiers feature + brief projet. Si le brief projet porte `clients:` → lire aussi le brief client (pile verticale).
3. Produire en conversation :

```
# Contexte feature — <Feature Name> · <Projet>

## Objectif feature
<1-2 lignes depuis feature/brief>

## Décisions prises (ne pas re-débattre)
<3-5 puces>

## Dernière session
<2-3 lignes>

## Blocages ouverts
<liste ou "Aucun">

## Contraintes projet parent
<1-2 lignes depuis projet/brief — contraintes qui s'appliquent à cette feature>

## Contexte client
<si projet client : 1 ligne depuis client/brief — contraintes durables du compte ; sinon omettre>
```

4. Mettre à jour `_STATE.md` frontmatter : écrire `projet_actif: "[[<projet>]]"` et `feature_active: "[[<N-slug>]]"`.
5. Attendre l'instruction. Ne pas agir avant.

## Outputs
Résumé en conversation uniquement. Aucun fichier écrit.

## Escalade
Feature introuvable → lister les features disponibles dans `features/` du projet.
