---
name: load-project
description: Charge le contexte complet d'un projet (memory/) avant de travailler dessus — brief, décisions, blocages ouverts, dernière session
---

Projet : $ARGUMENTS

## Mission
Donner à l'IA le contexte d'un projet vault avant d'agir. Charge **4 fichiers core** (budget ≤5K tok), `apprentissages`/`evals` en **lazy** (seulement en travail profond sur le projet). Résumé en conversation, zéro fichier écrit.

## Inputs
| Fichier | Couche | Sections | Charge | Pourquoi |
|---|---|---|---|---|
| `<projet>/memory/brief.md` | L3 | tout | **core** | contexte, objectif, contraintes — à internaliser |
| `<projet>/memory/decisions.md` | L3 | tout | **core** | choix structurels déjà pris — ne pas re-débattre |
| `<projet>/memory/blocages.md` | L4 | `statut: ouvert` | **core** | ce qui bloque actuellement |
| `<projet>/memory/sessions.md` | L4 | 2 entrées top | **core** | où on en était à la dernière session |
| `Clients/<c>/memory/brief.md` | L3 | tout | **core si projet client** | contexte durable du compte (haut de la pile client→projet, DOCTRINE#memory) |
| `<projet>/memory/apprentissages.md` | L3 | tout | **lazy** | pièges à éviter — charger si on travaille en profondeur (grossit, ~1,4K tok) |
| `<projet>/memory/evals.md` | L4 | dernière entrée | **lazy** | qualité dernière itération — charger sur demande |

(`<projet>` = `DATA/1-Projects/<area>/<slug>`)

## Process
1. Résoudre `<slug>` depuis `$ARGUMENTS` (kebab-case). Si ambigu → escalade.
2. Localiser le dossier : `find DATA/1-Projects -type d -name "<slug>"`. Si absent → escalade.
3. Lire les **4 fichiers core** (brief, decisions, blocages, sessions 2 top). Si le brief porte `clients:` → lire aussi le brief client (pile client→projet). `apprentissages`/`evals` seulement si travail profond (sinon skip = budget économisé).
4. Produire en conversation :

```
# Contexte — <Nom Projet>

## Ce qu'on construit
<1-2 lignes depuis brief : objectif + contraintes clés>

## Décisions structurelles (ne pas re-débattre)
<3-5 puces, décisions les plus récentes>

## Blocages ouverts
<liste ou "Aucun">

## Dernière session
<résumé 2-3 lignes : ce qui a été fait, ce qui suit>
```
(Section `## Pièges connus` ajoutée seulement si `apprentissages` chargé — lazy.)

5. Attendre l'instruction de travail de Hippo. Ne pas agir avant.

## Outputs
Résumé contexte en conversation uniquement. Aucun fichier écrit.

## Escalade
- Slug introuvable dans `DATA/1-Projects/` → demander l'area ou le chemin exact.
- Fichier memory manquant → signaler mais continuer avec les fichiers présents.
