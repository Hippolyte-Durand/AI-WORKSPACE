---
name: ticket
description: Crée un ticket (note incident) depuis un mail/texte collé, auto-lié aux entités du vault
disable-model-invocation: true
---

Source : $ARGUMENTS
(texte/mail collé, ou référence à un thread Gmail à lire via MCP `search_threads`/`get_thread` — lecture seule)

## Mission
Transformer une demande entrante (mail, appel, message) en note `incident` correctement typée et liée. Un ticket ops EST un incident.

## Inputs
| Fichier | Couche | Sections | Pourquoi |
|---|---|---|---|
| `SCHEMA.md#incident` | L3 | table champs | frontmatter exact (status/importance/created/due/liens) |
| `DB/relations_map.yaml` | L3 | entrées candidates | résoudre client/contact/machine existants (jamais grep) |
| texte ou thread Gmail | L4 | tout | la demande à traiter |

## Process
1. Extraire du texte : client, contact, machine(s), symptôme, urgence, échéance éventuelle.
2. Résoudre chaque entité contre le vault (QMD `lex` + `relations_map.yaml`). **Entité introuvable → escalade, ne crée JAMAIS l'entité toi-même.**
3. Créer `DATA/3-Resources/Incidents/<Titre-court>.md` :
   ```yaml
   type: incident
   status: ouvert
   importance: bas|moyen|haut   # déduit du texte ; ambigu → escalade
   created: YYYY-MM-DD
   due: YYYY-MM-DD              # seulement si déductible (SLA, "pour vendredi")
   clients: ["[[<slug>]]"]
   contacts: ["[[<slug>]]"]
   machines: ["[[<hostname>]]"]  # si identifiées
   ```
   Corps : `## Contexte` (source : mail/tel + extrait pertinent), `## Symptôme`, `## Actions`.
4. `python3 _APP/sync-all-bidirectional-links.py` (liens incident ↔ client/machine).

## Outputs
- 1 note incident dans `DATA/3-Resources/Incidents/`.
- Validation : `python3 _APP/check-vault-integrity.py` (doit passer).

## Escalade
Client/contact/machine non résolu dans le vault ; importance ambiguë ; texte qui décrit plusieurs incidents distincts (proposer découpage). (→ `GOUVERNANCE.md#escalade`)
