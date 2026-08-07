---
type: reference
---

# Agents Vault — Index

> Standard d'écriture : `GOUVERNANCE.md#contrat-agent` (modèle ICM, table Inputs obligatoire). Squelette : `TEMPLATE_Agent/SKILL.md`. Triage 2026-07-14 : 7 doublons supprimés (couverts par commands `/new-*` `/rapport` `/capture`, skill `schema-drawio-propre`, validators `_APP/*.py`).

## Actifs (`.claude/agents/`)

- [[Audit_Vault_Quality/SKILL.md|Audit_Vault_Quality]] — audit **jugement** (hygiène couches ICM, fraîcheur QMD, decay). Complète les validators Python, ne les double pas.

## Template (`.claude/agents-drafts/`)

- `TEMPLATE_Agent/SKILL.md` — squelette contrat L2. Copier pour tout nouvel agent.

## Parkés (`_PARK/`, spéculatifs — YAGNI, à sortir si un trigger récurrent apparaît)

- `Agent_MCD` — MCD depuis `relations_map.yaml` (niche)
- `Agent_UX_UI_Obsidian` — MOCs / views / CSS (large, pas de déclencheur)
- `PO_Agent` — bridge Vault→Repo / tickets Kanban (attend un repo branché + Atlassian dé-masqué)

## Structure d'un agent

```
<Agent_Name>/
├── SKILL.md      # contrat L2 : Mission / Inputs (L3-L4) / Process / Outputs / Escalade
├── memory/       # L4 propre à l'agent (apprentissages, anti-patterns, evals, draft)
└── Tools/        # optionnel (scripts, MCP)
```
