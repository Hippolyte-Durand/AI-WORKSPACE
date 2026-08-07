Agent opérationnel : Second Cerveau Obsidian. Règles : KISS + Terse + vault-as-memory.

**Lecture IA — quand lire quoi (racine vault) :**

| Fichier | Rôle | Lire quand |
|---------|------|------------|
| `GOUVERNANCE.md` | Routing intention→outil, contrat agents ICM | Avant créer/modifier agent ou skill |
| `DOCTRINE.md` | Règles détaillées vault (rangement, memory, types) | Décision structurelle, doute sur règle |
| `SCHEMA.md` | Ontologie : types fermés, champs, relations inter-notes | Créer/modifier note → lire **seulement la section du type** (header backtické `` ### `<type>` ``, jusqu'au prochain `### `), pas le fichier entier |
| `WORKFLOW.md` | Cycle agentique, étapes d'exécution | Exécuter un flux vault |
| `GESTION_PROJET.md` | Système tâches/jalons (type:task, phases, .base) | Créer/requêter tâches projet |
| `HIPPO.md` | Profil compressé (contexte rapide) | Tout contexte utilisateur |
| `HIPPO-full.md` | Profil complet | Personnalisation profonde, on demand seulement |
| `_STATE.md` | État courant vault | Reprise session, état projets |

**Gouvernance IA :** `GOUVERNANCE.md` = couche L1 (routing intention→outil) + doctrine d'écriture des skills/commands/agents `.claude` (modèle ICM 5 couches, table Inputs obligatoire). Lire avant de créer/réécrire un agent.

**Architecture :** HOME.md (dashboard racine, embeds `![[X.base]]`) + views/ par entité · DATA/ (Inbox/Projects/Resources/Archive, tu édites) · DB/ (relations_map.yaml, .base, ne pas toucher à la main).

**Rangement :** area unique (Perso/Pro/Ecole/Business/Certifs), TYPE décide chemin, code → repo séparé, zéro scaffold spéculatif → DOCTRINE.md#foyer-unique.

**Memory :** Projet = 6 fichiers (apprentissages, blocages, brief, decisions, evals, sessions) ; Client = 5 (pas d'evals). Entrées `### YYYY-MM-DD — Titre`, draft/ pour brouillons, `/capture` EOD → DOCTRINE.md#memory.

**Documentation :** No production codebase in vault (→ separate repos) ; learning snippets/examples OK in KB (type: concept/outil/procedure). Infra → `3-Resources/Infra/`, logs → `3-Resources/IA/Logs_IA/` (type `ai_log`).

**Tools :** QMD first (search/query, pas grep) — serveur MCP `qmd` disponible via ruler. Relations → `relations_map.yaml` source unique (généré par script Python, pas graphify). `/graphify` → `GRAPH_REPORT.md` only. Schémas → `schema-drawio-propre`.

**Ontologie :** Types, champs, relations inter-notes → `SCHEMA.md` (racine). Lire en premier pour comprendre le graphe du vault.

**Intégrité :** Frontmatter links quotés, types fermés (VALID_TYPES), cockpits `<slug>.md`. Erreurs : lis + corrige + relance, 3 fails → DATA/0-Inbox/ `#erreur-capture`.

**Vérification OBLIGATOIRE (gate anti-drift) :** après TOUTE édition de note, template (`_TEMPLATES/`), commande/skill (`.claude/`) ou `.base`, lancer `python3 _APP/check-vault-integrity.py` **avant de conclure le tour**. 0 erreur exigé. C'est le moteur de règles unique (types fermés, FK dures, liens quotés, typage strict, templates↔SCHEMA, **prose /new-\* sans FK singulier déprécié**). Il tourne déjà au Stop hook + git pre-commit — ne jamais le contourner ni committer rouge. Champ FK = **toujours pluriel array** (`clients:`/`projets:`/`parents:`, jamais `client:`/`projet:`/`parent:`) ; noms de champ = `SCHEMA.md` (contact : `poste`/`phone`, jamais `role`/`tel`). Nouvelle règle de conduite → l'encoder comme fonction `rule_*`/`check_*` dans le checker, pas seulement en prose.

**Planification :** Avant toute action non-triviale, challenger avec 3 questions : (1) Ça doit exister ? (2) C'est déjà là ? (3) Impact irréversible ? Jamais tête baissée sur scope ambigu.

**Plan avant exécution (obligatoire) :** Toute tâche non-triviale = planifier d'abord avec le mécanisme de plan de ton CLI (Claude Code : `EnterPlanMode` ; sinon : énoncer le plan étape par étape et attendre validation). Le plan se construit avec jugement — arbitrages, découpage en étapes atomiques (fichiers cibles, critère de fait). Le plan validé devient le garde-fou de l'exécution.
- Cas complexes (multi-fichiers, décision structurelle, ambiguïté) → garder le modèle le plus capable pour le raisonnement.
- Exécution : découper en étapes atomiques ; déléguer aux subagents/étapes si le CLI le permet (Claude Code : subagents `model: haiku`). Le plan détaillé = contexte suffisant.
- Règle de déclenchement : toute demande impliquant raisonnement OU implémentation → plan par défaut. Si doute sur la trivialité → **demander** ("Plan ?") et attendre oui/non. Jamais décider seul de sauter le plan.

**Scope session :** Une session = un projet actif + une feature active (optionnel). Toute modification scopée à ce contexte. Idée hors-scope → capturer dans `memory/sessions.md` du projet concerné, pas exécuter maintenant. Switch explicite requis pour changer de projet.

---

## Routing automatique (L0 — actif chaque réponse)

Priorité décroissante : feature > projet > client > vault global.

### 1. Reprise de session
Signal : premier message vague ("reprends", "où on en est", "suite", "status", "continue").
Action : lire `_STATE.md` → répondre état courant + prochaines actions. Ne pas demander.
Si `feature_active:` non vide dans `_STATE.md` → charger le contexte feature automatiquement (§2).

### 2. Contexte feature (le plus précis)
Signal (par ordre de priorité) :
- Slug exact mentionné (`01-core-dashboard`, `03-mail`)
- Mot-clé partiel qui matche une feature du projet actif (`"mail"` → `03-mail`, `"dashboard"` → `01-core-dashboard`, `"IA"` → `05-ia-actions`)
- Formulation fonctionnelle (`"travaille sur le mail"`, `"feature calendrier"`, `"la partie projets"`)

Auto-détection :
1. Si projet actif connu → `ls features/` pour lister les features disponibles.
2. Matcher le terme mentionné contre les slugs/descriptions des features (fuzzy : `mail`→`03-mail`, `calendar`→`04-calendar`, `ia`→`05-ia-actions`).
3. Si 1 match → charger en silence. Si 0 ou >1 match ambigu → proposer la liste et demander.
4. Lire : `features/<N-slug>/memory/brief.md` → `decisions.md` → `sessions.md` (2 top) → `blocages.md`.
5. Lire la **pile brief verticale** : `<projet>/memory/brief.md`, et si le brief projet porte `clients:` → `Clients/<c>/memory/brief.md` (scopes client→projet→feature, cf. `load-feature` + DOCTRINE#memory).
6. Résumer contexte, attendre instruction.

Commande explicite : `/load-feature <projet> <N-slug>`

### 3. Contexte projet
Signal : slug projet mentionné, tâche projet évoquée, `/load-project` invoqué.
Action :
1. Lire `memory/` core : `brief.md` → `decisions.md` → `sessions.md` (2 top) → `blocages.md`. Si `brief` porte `clients:` → aussi le brief client (pile). `apprentissages`/`evals` = lazy (travail profond seulement).
2. Lister les features disponibles (`ls features/` si le dossier existe) — les garder en tête pour la détection feature (§2).
Localisation : `find DATA/1-Projects -type d -name "<slug>"` si ambigu.
Commande explicite : `/load-project <slug>`

### 3b. Création feature détectée
Signal : formulation évoque une nouvelle capacité qui n'existe pas encore comme feature (`"il faudrait...", "je veux ajouter...", "nouvelle feature pour...", "et si on créait...", "un module pour..."`).
Action :
1. Vérifier que le projet actif est connu. Sinon → demander.
2. Lister les features existantes (`ls features/`) → vérifier que ça ne matche pas déjà une feature existante.
3. Si nouveau : proposer un slug numéroté (`NN-<slug-kebab>`) + description 1 ligne. Attendre confirmation.
4. Sur confirmation → exécuter `/new-feature <projet> <NN-slug>` automatiquement.

Ne pas créer sans confirmation — une feature est une décision structurelle.

### 4. Contexte client
Signal : nom ou slug client mentionné.
Action : lire `DATA/3-Resources/Clients/<slug>/memory/` : `brief.md` → `sessions.md` (2 top) → `blocages.md`.
Commande explicite : `/briefing <client>` (RDV) ou lecture directe.

### 5. Création/modif note
Signal : création ou édition d'une note avec frontmatter.
Action : lire **la seule section du type dans `SCHEMA.md`** — pas le fichier entier (3k+ mots). Headers backtickés : `` ### `projet` ``, `` ### `contact` ``. Méthode : `grep -n '^### ' SCHEMA.md` → repérer la ligne `` ### `<type>` `` et la suivante → lecture scopée (offset=ligne ancre, limit=lignes jusqu'au prochain `### `). Foyer du fichier → table `DOCTRINE.md#foyer-unique` (dossier→fonction).

### Hiérarchie Projet → Feature → Tâche
```
Projet  = objectif macro (semaines/mois) · memory 6 fichiers · gate = toutes features livrées
 └─ Feature = unité livrable parallélisable · memory 4 fichiers · gate = toutes tâches à 0
     └─ Tâche  = action atomique · 1 critère de fait · pas de memory
```
Chemin feature : `DATA/1-Projects/<area>/<projet>/features/<N-slug>/`
