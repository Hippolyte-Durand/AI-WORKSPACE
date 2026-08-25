---
name: notion-create-project
description: Créer un projet structuré dans Notion DB-Projets (Initiative → Projet → Feature → Tâche) selon la charte de hiérarchie. Trigger : "crée un projet Notion", "structure ce projet dans Notion", /notion-create-project.
---

# notion-create-project

Automatise la création d'un projet dans **DB-Projets** (une seule base, différenciée par le champ `Type`), conforme à la charte de hiérarchie du workspace.

## Constantes (IDs vérifiés)

| Élément | ID |
|---|---|
| DB-Projets (data source) | `collection://32e9fa5e-9b43-81f6-baff-000bc6b75cfa` |
| DB Stacks & Outils | `collection://2d79fa5e-9b43-810d-bb70-000be2f8db01` |
| DB Brief (relation) | `collection://31e9fa5e-9b43-836a-bafa-07e17179bce7` |
| DB Documents (relation) | `collection://86f2109c-c089-41f6-a2d5-e19edfd399ab` |
| DB Procédures & Runbooks | `collection://2d79fa5e-9b43-8127-a221-000b4c59a214` |
| KB source RAG | `f9fea12b-5708-4ef2-b51a-5773e792b328` |

**Champs DB-Projets** : `Nom` (title), `Type` (select), `Statut` (status), `Priorité` (select), `Parent`/`Enfants` (relation self), `Stacks & Outils`/`Topics`/`Concepts`/`Area`/`Brief`/`Documents`/`Procédures & Runbooks`/`Memory`/`Meeting`/`Entreprise` (relations), `git` (url), `Dates` (date).

**Valeurs `Type`** : `🎯 Initiative` · `📁 Projet` · `🧩 Feature` · `✅ Tâche`
**Valeurs `Statut`** : `📥 Backlog` · `🔄 En cours` · `👀 En review` · `✅ Terminé` · `❌ Annulé`
**Valeurs `Priorité`** : `🔴 Critique` · `🟠 Haute` · `🟡 Moyenne` · `🟢 Basse`

## Modèle (charte)

- **🎯 Initiative** = produit/engagement, racine, ne se termine jamais. Parent = aucun.
- **📁 Projet** = un livrable déclarable livré et fermé. Parent = Initiative.
- **🧩 Feature** = **une branche Git** (`feature/<kebab-case>`), OPTIONNELLE. R8 : **pas de repo, pas de Feature** → tâches direct sous Projet. Nom = kebab-case sans préfixe `feature/`. Lien branche dans `git`.
- **✅ Tâche** = unité < 1 jour. Parent = Projet OU Feature.
- **R1** : un Projet est un livrable, jamais une couche technique (pas de « Front/Backend/Tests »).
- **R3** : fratrie homogène (même granularité).
- Brief = **corps de la page Projet** (pattern cockpit : Contexte/Objectif/Périmètre/Stack/Décisions/Sessions/Blocages/Apprentissages/Doc liée).

## Procédure

1. **Lire la charte** si doute : chercher "Charte de hiérarchie & Plan de refonte — DB-Projets" via `notion-search`.
2. **Initiative** : si le projet a besoin d'une racine, `notion-create-pages` (parent = data_source DB-Projets), `Type=🎯 Initiative`. Récupérer l'URL retournée.
   - Si `Type=🎯 Initiative` rejeté (option absente) → `notion-update-data-source` : `ALTER COLUMN "Type" SET SELECT('🎯 Initiative':blue, '📁 Projet':default, '🧩 Feature':purple, '✅ Tâche':brown)`. Notion matche par nom → préserve les descriptions. **Re-fetch pour vérifier** qu'elles ont survécu.
3. **Projet** : `notion-create-pages`, `Type=📁 Projet`, `Parent=[<id Initiative>]`. Corps : préférer `template_id="32e9fa5e-9b43-8182-889f-d5f080864f29"` (template "Projet", scaffold généré côté serveur → moins de tokens émis) + propriétés ; sinon `content` markdown. Récupérer l'URL.
4. **Features** (seulement si branche Git) : `Type=🧩 Feature`, `Parent=[<id Projet>]`, nom kebab-case, `git=<url branche>`.
5. **Tâches** : `notion-create-pages` en **un seul batch**, chaque tâche `Type=✅ Tâche`, `Parent=[<id Projet ou Feature>]`, `Statut`, `Priorité` si backlog.
6. **Étiquettes** : lier `Stacks & Outils`/`Topics` via relation. Query la DB Stacks (`SELECT url, Nom WHERE Nom LIKE ...`) pour récupérer les URLs ; créer l'entrée si absente.
7. **Documentation** : **lier, jamais dupliquer**. Chercher les pages doc existantes (`notion-search`), les référencer dans le brief ou via relation `Documents`.

## Gotchas

- **Relation Parent** = array de **page IDs bruts** `["3c09fa5e9b43..."]` (plus court que l'URL complète, accepté par l'API). Créer le parent AVANT l'enfant pour avoir son ID.
- **Batch atomique** : une seule URL malformée rejette tout le batch `create-pages`. Vérifier chaque URL.
- **Feature sans branche** = dérogation R8 → la vue 🚨 Anomalies / propriété ⚠️ Conformité la flagge « branche manquante ». Laisser une note, remplir `git` dès qu'une branche existe.
- **Reparenter une tâche** : `notion-update-page` command `update_properties`, `{"Parent": ["<url feature>"]}`.
- **Icône = template Notion, pas emoji** — pour poser l'icône native de galerie (folder/document/brain…), passer `icon` = URL `https://www.notion.so/icons/<nom>_<couleur>.svg` (Notion la mappe sur l'icône de galerie). DB-Projets → `folder_purple`, DB-Brief → `document_purple`, DB-Memory → `brain_purple`. Jamais d'emoji.

## Token-discipline (voir skill notion-token-efficient)

- Lire une page → `mcp__notion-cli__API-retrieve-page-markdown` (jamais `get-block-children`).
- Lire des lignes → `notion-query-data-sources` SQL projeté (jamais `SELECT *`).
- Écrire → `notion-create-pages` en enhanced markdown (jamais blocs JSON).
- **Réduire les tokens d'écriture** : `template_id` pour le scaffold (corps généré serveur), IDs bruts au lieu d'URLs dans les relations, un seul batch.

## Offload écriture à n8n (récurrent)

**Full-tree** — workflow **`Notion · Create Project Tree`** (id `AaAQsztv6k0TxJvR`, actif) :
```
POST http://localhost:5678/webhook/create-project-tree
{
  "projet": { "nom": "...", "initiative_id": "<id>", "statut": "🔄 En cours", "priorite": "🟠 Haute" },
  "brief":  { "objectif": "...", "contexte": "...", "criteres": "...", "livrable": "..." },
  "memory": { "decisions": "...", "sessions": "...", "apprentissages": "...", "source": "Discussion IA" },
  "taches": [ { "nom": "...", "priorite": "🟡 Moyenne" } ],
  "features": [ {
    "nom": "kebab-name",
    "brief":  { "objectif": "..." },
    "memory": { "decisions": "..." },
    "tasks":  [ { "nom": "..." } ]
  } ]
}
```
→ crée en 1 POST : Projet (parent=initiative) + **Brief + Memory du Projet** + tâches directes + Features (parent=projet), **chaque Feature avec son Brief + Memory** + tâches de feature. Tout lié (relations Parent/Enfants + Brief/Memory dual).
- **Brief + Memory sont TOUJOURS créés** (Projet ET chaque Feature) — systématique. Les objets `brief`/`memory`/`feature.brief`/`feature.memory` du payload ne portent que le **contenu** (optionnel) ; omis = Brief/Memory minimal auto (titre + relation).
- ÷4-5 tokens. `responseMode: onReceived` (fire-and-forget, 200 immédiat).
- **database_id API** (parent Notion, avec tirets ou non) : DB-Projets `32e9fa5e9b4380b0b68bfe1921f9fc1f` · DB-Brief `3af9fa5e9b4383579e120129a2aa6052` · DB-Memory `ac12089c4487445e8c6b25b529d212b4`.
- Brief = corps de page allégé + source unique dans la relation `Brief`/`Memory` (pas de duplication narrative dans le corps du Projet).

**Projet seul** — workflow `Notion · Create Project` (id `BKVYCkgNRkXqIc6J`), `POST /create-project` avec `{nom, initiative_id, type, statut, priorite}`. (Pas de Brief/Memory ni sous-arbre — préférer le full-tree.)

**Gotchas n8n (durement gagnés)** :
- Le parser d'expression n8n (Tournament) **ne supporte PAS** `?.` ni `??`, et casse sur un objet littéral complexe inline dans `{{ }}` → `invalid syntax`. **Construire le JSON body dans un node Code** (vrai JS), pas en expression inline. HTTP `jsonBody = {{ $json.notionBody }}`.
- HTTP Request cred `notionApi` (predefined) : header `Notion-Version: 2022-06-28`, parent `{ "database_id": "..." }`.
- Credential pas auto-bindée sur HTTP predefined → `setNodeCredential` (id `lddwAEajOHP1kOZe`).
