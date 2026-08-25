---
name: load-notion-context
description: Charge le contexte hiérarchique d'un item Notion DB-Projets (Tâche/Feature/Projet/Initiative) avant de travailler dessus. Remonte la chaîne Parent jusqu'à la racine via la pipeline n8n "Notion · Load Context". Trigger — "charge le contexte de <item>", "load-notion-context <id|url>", /load-notion-context.
---

# load-notion-context

Récupère la chaîne d'ascendance complète d'un item Notion (racine → item) et la
charge dans le contexte, pour bosser avec tout le contexte projet/feature/tâche.

## Usage

Donne un **ID de page** ou une **URL Notion** de l'item (Tâche, Feature, Projet ou
Initiative de DB-Projets). Puis appelle la pipeline n8n :

```bash
curl -sS -X POST http://localhost:5678/webhook/load-context \
  -H 'Content-Type: application/json' \
  -d '{"page_id":"<ID_OU_URL_NOTION>"}'
```

La pipeline accepte un id à tirets, sans tirets, ou une URL complète (elle extrait
l'UUID). Elle interroge DB-Projets, remonte `Parent` jusqu'à la racine (plus de
parent), et renvoie un **briefing markdown prêt à charger** (`Content-Type:
text/markdown`).

Options dans le body (toutes facultatives) :

- `"full": true` — corps non tronqués (comportement d'origine).
- `"max_body": N` — troncature du corps des pages de la chaîne (défaut 2000 car.).
- `"max_linked": N` — troncature des corps brief/memory (défaut 1500 car.).
- `"include": "all" | "brief" | "memory" | "none"` — limite les pages liées
  fetchées (défaut `all` ; `none` = chaîne seule, réponse ~1 KB).

Les coupures sont signalées par `[… tronqué, N car. au total]`. Si un corps est
tronqué et que la suite est nécessaire, relire la page via le MCP Notion.

## Réponse

Markdown, ordonné **racine → item** :

```markdown
# Contexte — <nom item> (<type>)

## Chaîne hiérarchique
📁 Projet  · Industrialiser Nexa Cloud
  └ 🧩 Feature  · Images & provisionnement
      └ ✅ Tâche  · Template Packer WS2025   ← item demandé

## Détails par niveau
### <type> — <code · nom>
Statut: … · Priorité: …
<url>
<corps de page (tronqué)>
**Brief:** …
**Memory:** …
```

Les champs vides/nuls sont omis. Corps tronqués → marqueur `[… tronqué, N car.
au total]` ; relire la page via le MCP Notion si la suite est nécessaire.

## Après l'appel

Charge le briefing tel quel dans le contexte : la section « Chaîne hiérarchique »
situe l'item, « Détails par niveau » donne le contenu. Puis travaille sur l'item
demandé (dernier maillon, marqué `← item demandé`).

## Détails

- Pipeline n8n : `Notion · Load Context (webhook)` — workflow `EptZ3gt4QNMB8QMn`.
- Toute la logique (requête Notion, remontée, enrichissement) vit dans n8n ; ce
  skill n'est que l'appel HTTP.
- DB-Projets interroge la base de prod (`32e9fa5e-...`, sous NEXA CLOUD → DB -
  PROD), paginée à 100 lignes/requête (max 10 requêtes).
- Limites connues : corps de page lus sur les 100 premiers blocs, puis tronqués
  par défaut dans la réponse (voir options `full` / `max_body` / `max_linked`).
