---
name: briefing
description: Briefing avant RDV client — agenda + historique vault + mails récents (lecture seule)
---

Client ou RDV : $ARGUMENTS
(si vide, prends le prochain RDV client dans Calendar sous 48h)

## Mission
Préparer Hippo avant un RDV client : contexte relation, incidents ouverts, derniers échanges, points à aborder. Output conversation, zéro fichier.

## Inputs
| Fichier | Couche | Sections | Pourquoi |
|---|---|---|---|
| Calendar MCP `list_events` | L4 | prochaines 48h | identifier le RDV et le client |
| `Clients/<slug>/memory/sessions.md` | L4 | 3 dernières entrées | derniers contacts |
| `Clients/<slug>/memory/blocages.md` | L4 | `statut: ouvert` | irritants chroniques |
| incidents du client | L4 | `status != resolu` (QMD/Incidents.base) | dossiers chauds |
| Gmail MCP `search_threads` | L4 | from:contact, 30 j | échanges récents |

Tout est L4 (artefacts à traiter). Lecture seule sur Gmail/Calendar — aucun envoi, aucun event créé.

## Process
1. Identifier le RDV (Calendar ou $ARGUMENTS) → mapper au client vault (QMD lex ; introuvable → escalade).
2. Charger uniquement les sections nommées ci-dessus.
3. Produire dans la conversation :

# Briefing — <Client> — <date/heure RDV>
## Contexte relation
<2-3 lignes : où on en est, dernier contact>
## Incidents ouverts
<liste status + importance + âge ; "Aucun" si vide>
## Derniers échanges
<2-3 threads mail résumés en 1 ligne chacun>
## Points à aborder
<max 5, actionnables, tirés des blocages/incidents/mails>

## Outputs
Briefing en conversation uniquement. Aucun fichier écrit → pas de validation vault.

## Escalade
Client du RDV introuvable dans le vault ; RDV ambigu (plusieurs candidats sous 48h → demander lequel). (→ `GOUVERNANCE.md#escalade`)
