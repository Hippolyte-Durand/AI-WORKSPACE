---
name: ragq
description: Interroger le RAG personnel (Notion→Supabase, 7 sources, bge-m3 + expansion graphe) depuis le terminal via le script ragq. Trigger : /ragq, "cherche dans mon rag", "interroge le rag", "qu'est-ce que ma doc dit sur…".
---

# ragq

Interroge le RAG/GraphRAG (chunks Notion indexés dans Supabase `rag_documents`, embeddings Ollama `bge-m3`, expansion graphe 1-saut via `match_rag_documents`). Le vecteur et la clé `service_role` restent dans le process — seuls les résultats reviennent.

## Utilisation

Lancer le script via Bash (jamais réimplémenter l'embed/la requête à la main) :

```bash
ragq "<question de l'utilisateur>"
```

Chemin : `ragq` (si `~/bin` dans le PATH) sinon `~/bin/ragq` ou `/Users/hippo/ai-workspace/bin/ragq`.

**Flags :**
- `-k N` : nombre de résultats seed (défaut 6 ; le graphe ajoute jusqu'à N voisins → total ≈ 2×N).
- `-s <source>` : filtre par source — `kb` (alias `blob`), `db-projets`, `concepts`, `topics`, `runbooks`, `stacks`, `documents`.
- `-c` : affiche un extrait (~220 car) du contenu de chaque chunk.

Exemples :
```bash
ragq "cluster Hyper-V haute disponibilité"
ragq -k 10 -c "sauvegarde et restauration Veeam"
ragq -s runbooks "configurer Sophos HA actif-passif"
```

## Sortie

Lignes `similarity  source  titre` (+ extrait avec `-c`), triées par pertinence. Les seeds = matches vectoriels ; les entrées de plus faible score en fin = voisins ramenés par le graphe (relations Notion).

## Process (pour l'agent) — token-lean

1. **Lancer `ragq` en Bash direct** (ne PAS charger ce skill ni un MCP pour ça : Bash n'a aucun overhead de schéma). Cette page n'est utile qu'au premier usage / si doute.
2. Sortie **compacte par défaut** (titre/source/sim ≈ 200 tok). N'ajouter `-c` que si tu dois vraiment lire le contenu pour répondre (~1,2K tok).
3. Prendre la question telle quelle. Flags : `-s` si type ciblé (procédures→runbooks, définitions→concepts, projets→db-projets), `-k` plus grand seulement si trop peu de résultats.
4. **Format de réponse à l'utilisateur** — toujours deux blocs :
   - **Réponse** : synthèse structurée de ce que disent les chunks (organisée, pas un dump ; réponds à la question).
   - **Sources** : la liste que `ragq` imprime après `SOURCES:`. Afficher l'**URL https brute et visible** (pas de lien markdown à titre masqué) — seules les URLs http(s) nues sont Cmd+cliquables en CLI (ouvre le navigateur puis l'app). **Numéroter les sources** pour permettre "ouvre la N".

### Ouvrir une source direct dans l'app desktop
Un clic terminal passe toujours par le navigateur. Pour ouvrir DIRECT l'app Notion : l'agent lance en Bash `open "notion://app.notion.com/p/<slug-id>"` (convertir l'URL https → `notion://`). macOS route le scheme vers l'app, sans navigateur. Déclencheur : l'utilisateur dit "ouvre la source N" / "ouvre <titre>".
5. Si `aucun résultat` : élargir `-k`, retirer `-s`.

`ragq` imprime déjà le bloc `SOURCES:` (docs dédupliqués + `source_url`). Reprends-le tel quel dans la section Sources.

Règle : commence toujours par une passe compacte (sans `-c`) ; ne récupère le contenu que sur les 1-3 chunks réellement pertinents (2e appel `-c -k 3` ou lecture ciblée). Évite de rapatrier 6 chunks de contenu si 2 suffisent.

## Prérequis / dépannage

- Clé : `~/.config/rag/.env` → `SUPABASE_SERVICE_KEY=` (Supabase → Settings → API Keys → service_role). Sans ça : erreur "manque SUPABASE_SERVICE_KEY".
- `embedding échoué` → Ollama pas lancé ou modèle absent (`ollama pull bge-m3`).
- `jq requis` → `brew install jq`.
- Config surchargeable : `SUPABASE_URL`, `OLLAMA_URL`, `EMBED_MODEL` dans le même `.env`.

## Voisins

Pipeline d'ingestion = workflows n8n `RAG · Sync …` (KB 15 min, DB-Projets/Concepts/Topics/Runbooks/Stacks/Documents quotidiens) + `RAG · Reconcile orphelins`. Graphe = `rag_pages`/`rag_page_edges` (relations Notion). Écriture doc = Notion (source éditoriale). Voir aussi [[notion-token-efficient]].
