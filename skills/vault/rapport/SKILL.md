---
name: rapport
description: Génère un rapport d'avancement pour un projet
disable-model-invocation: true
---

Projet : $ARGUMENTS
(si vide, déduis depuis les fichiers ouverts ou demande)

## Inputs
Tout L4 (artefacts du projet, à traiter comme source). Lis **dans cet ordre** :
| Fichier | Couche | Sections | Pourquoi |
|---|---|---|---|
| `<slug>/memory/brief.md` | L4 | tout | contexte & objectifs |
| `<slug>/memory/sessions.md` | L4 | 2–3 dernières | activité récente |
| `<slug>/memory/decisions.md` | L4 | 3 dernières | choix structurants |
| `<slug>/memory/blocages.md` | L4 | `statut: ouvert` | ce qui bloque |
| `<slug>/memory/evals.md` | L4 | dernière | note /5 |

Base : `DATA/1-Projects/<slug>/`.

Produis le rapport ci-dessous **dans la conversation** (ne crée pas de fichier sauf si demandé) :

---

# Rapport d'avancement — <Projet> — <YYYY-MM-DD>

## Statut global
`<statut>` · <une ligne sur où en est le projet>

## État

## Sessions récentes
<Résumé des 2–3 dernières sessions : ce qui a été fait, ce qui suit.>

## Décisions clés
<3 dernières décisions structurantes : choix + pourquoi en 1 ligne chacune.>

## Blocages ouverts
<Blocages `statut: ouvert` avec symptôme. "Aucun" si vide.>

## Évaluation
Note <N>/5 — <Bien> / <Raté> en 1 ligne chacun.

## Prochaines étapes
<Tâches "🔄 En cours" + "Suite" de la dernière session. Max 5 items.>

---

Règles : concis (≤ 3 lignes par section sauf Tâches), pourquoi avant quoi, rien d'inventé hors des fichiers. Si un fichier memory est absent ou vide, indique-le en 1 mot ("vide") et continue.
