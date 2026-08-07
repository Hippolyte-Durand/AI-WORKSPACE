---
name: po-agent-bridge
description: Décomposeur brief projet → tâches vault (Tasks.base). Draft — tout est vault-natif, pas de Repo/Kanban externe.
metadata:
  type: agent
  area: Perso
  status: draft
---

# PO Agent (draft)

## Mission

Décomposer un `brief.md` projet en tâches actionnables `type: task` (Tasks.base), avec critères d'acceptance. **Vault-natif** — pas de pont vers un repo/Jira externe (recadré 2026-07-15 : tout vit dans le vault).

## Statut

Draft parké. **Ne devient un outil que si le besoin devient récurrent.** Piste probable : command `/taches <projet>` (contrat L2 léger, zéro memory) plutôt qu'un agent — la décomposition brief→tâches est ponctuelle, pas un process avec mémoire propre.

## Inputs (esquisse — à figer à la promotion)
| Fichier | Couche | Sections | Pourquoi |
|---|---|---|---|
| `SCHEMA.md#task` | L3 | champs + types | format tâche correct |
| `<projet>/brief.md` | L4 | tout | specs à décomposer |

## Ouvert
- Agent vs command `/taches` ? (probablement command)
- Estimation complexité utile, ou juste liste de tâches ?
