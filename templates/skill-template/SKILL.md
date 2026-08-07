---
description: <une ligne — verb + objet + résultat. Sert au routing L1. Max 120 chars.>
---

# <Nom du Skill>

> Contrat L2 (ICM). Lire ce fichier + `anti-patterns.md` + `checklist-creation.md` (ce dossier) avant d'agir.
> Règle d'or : aucun agent ne lit tout — uniquement ce que la table Inputs déclare.

---

## Mission

<1-3 lignes : quoi, pour qui, critère de succès visible. Pas de "peut" ou "pourrait".>

**Trigger** : `/skill-name [ARGUMENTS]` — ou signal naturel : `<description du signal qui déclenche ce skill>`.

---

## Routing (L1) *(si multi-scope uniquement — supprimer si skill scope unique)*

Précédence : **feature > projet > client > vault global**. Appliquer CE scope uniquement, rien d'autre.

| Signal dans le message | Scope | Action |
|---|---|---|
| <signal spécifique A> | feature | <action concrète> |
| <signal spécifique B> | projet | <action concrète> |
| rien ne matche | — | lire `GOUVERNANCE.md#routing`, proposer avant d'agir |

> Scope fourni en `$ARGUMENTS` → priorité. Sinon → lire `_STATE.md` (`projet_actif:` + `feature_active:`).

---

## Inputs

> L3 = contrainte stable à internaliser (recette, règle). L4 = artefact du run à traiter (input qui change chaque fois). Ne jamais mélanger sans distinguer.

| Fichier | Couche | Sections | Pourquoi |
|---|---|---|---|
| `DOCTRINE.md` | L3 | `#<section-exacte>` | <contrainte spécifique — jamais fichier entier> |
| `SCHEMA.md` | L3 | `` ### `<type>` `` uniquement | champs + FK du type |
| `<projet>/memory/brief.md` | L4 | tout | contexte du run |
| `<artefact du run>` | L4 | <sections ciblées> | <pourquoi> |

**Anti-bloat** (violations = tokens gaspillés + dégradation) :
- `SCHEMA.md` → 1 section `### \`<type>\`` uniquement, jamais le fichier entier
- `relations_map.yaml` → `grep "<slug>" DB/relations_map.yaml`, jamais la map entière
- `graph.json` → interdit (121KB). Toujours `GRAPH_REPORT.md` (4.6KB)
- `memory/*.md` → 2 entrées récentes suffisent (récent en haut), jamais fichier complet
- Doute sur le budget → `python3 _APP/context-budget.py <scope>` avant de charger

---

## Process

> Chaque étape = 1 verbe + 1 cible (fichier/outil) + 1 critère de fait (ce qui prouve que c'est fait).
> Granularité : une étape qui "charge le contexte et met à jour les fichiers et valide" = 3 étapes.

1. **Budget** *(si scope > feature)* : `python3 _APP/context-budget.py <scope>` — si > 8K tokens, réduire les inputs L4 avant de continuer.
2. **Parse arguments** : extraire `<cible>` depuis `$ARGUMENTS`. Absent → lire `_STATE.md` frontmatter.
3. **Routing scope** *(si multi-scope)* : appliquer table Routing. Ambiguïté → lister candidats, demander.
4. **[Étape spécifique]** : <verbe> `<fichier>` via `<outil>` → critère : <ce qui change>.
5. **[Étape spécifique]** : <verbe> `<fichier>` → critère : <ce qui change>.
6. **Validation** : `python3 _APP/strict-validation.py` puis `python3 _APP/check-vault-integrity.py` → 0 erreur. Erreur → STOP, afficher, corriger, relancer. Après 3 échecs → escalade.

**Décisions déterministes** — aucun "si nécessaire" ou "au besoin" :
- Si `<condition A>` → `<action A exacte>`.
- Si `<condition B>` → `<action B exacte>`.
- Si condition inconnue → escalade (§Escalade), ne pas deviner.

---

## Outputs

> Déclarer chaque fichier écrit/modifié, son format, et ce qui prouve que le run est terminé.

| Fichier | Action | Format attendu |
|---|---|---|
| `<chemin/fichier.md>` | créé / mis à jour | section `### YYYY-MM-DD — <titre>` prépendée |
| `_STATE.md` | mis à jour | `projet_actif:` + `feature_active:` + phase + 3 prochaines actions |

**Sections datées** (memory — format obligatoire) :
```markdown
### YYYY-MM-DD — <Titre court>
<contenu — pourquoi avant quoi, concis, n'invente rien hors de la session>
```

**Validation finale** (ordre obligatoire) :
1. `python3 _APP/strict-validation.py` — DOIT passer.
2. `python3 _APP/check-vault-integrity.py` — DOIT passer, 0 erreur.

**Rapport conversation** (obligatoire, dernière ligne du run) :
```
[<SKILL-NAME>] <scope> | écrit: N | lu: M | OK
[<SKILL-NAME>] <scope> | écrit: N | lu: M | ⚠️ <message court>
```

---

## Memory (L4 propre au skill) *(optionnel — supprimer si skill sans état persistant)*

`memory/<fichier>.md` — <quoi stocker : runs notables, faux positifs, patterns appris>.
Format : `### YYYY-MM-DD — <titre>` prépendé (récent en haut).
Rollup à 10KB → sections >30j condensées en 1 ligne, détail → `memory/archive/<fichier>-YYYY-MM.md` (→ DOCTRINE#compaction).

---

## Vérification

> ≤ 3 scénarios. Chaque scénario = condition initiale + action + critère de fait observable.

| Scénario | Condition | Critère de succès |
|---|---|---|
| Cas nominal | <état initial normal> | <ce qu'on observe dans les fichiers ou la réponse> |
| Cas limite | <edge case clé> | <critère> |
| Cas erreur | <input invalide ou manquant> | escalade déclenchée, 0 écriture parasite |

---

## Escalade

| Situation | Action |
|---|---|
| Choix structurant non tranché (nouveau type, nouvelle area, doctrine) | Proposer 3 options, attendre confirmation Hippo |
| Validation échoue 3× | Déposer `#erreur-capture` dans `DATA/0-Inbox/`, signaler |
| Action irréversible (suppression, rename masse) | Décrire, attendre "oui" explicite |
| Scope ambigu (0 ou >1 match) | Lister les candidats, demander |
| Intention hors table Routing | Lire `GOUVERNANCE.md#routing`, proposer avant d'agir |

**Défaut absolu** : proposer, ne pas exécuter. Décision de gouvernance → Hippo.

---

## Tools disponibles

### Recherche & lecture vault
| Outil | Quand | Jamais |
|---|---|---|
| QMD `query`/`get` | contenu sémantique ("notes qui parlent de X") | structurel (header, clé FM) |
| `grep "<slug>" DB/relations_map.yaml` | relations entre entités (liens d'un slug) | map entière |
| `grep`/`find` direct | structurel (nom de fichier, clé frontmatter) | sémantique |
| `GRAPH_REPORT.md` + `/graphify` | graphe, communautés, god nodes | `graph.json` (121KB, interdit) |

### Scripts _APP/
| Script | Usage | Quand déclencher |
|---|---|---|
| `python3 _APP/check-vault-integrity.py` | types, FK, liens, symétrie | gate obligatoire après TOUTE édition note/template/.base |
| `python3 _APP/strict-validation.py` | pluriels, quotes, FM ultra-strict | avant capture/commit |
| `python3 _APP/sync-memory-downlinks.py` | downlinks cockpit (briefs/decisions/sessions/blocages) | après création feature/projet |
| `python3 _APP/build-relations-map.py` | rebuild `DB/relations_map.yaml` | après modifs FK massives |
| `python3 _APP/context-budget.py <scope>` | mesure tokens scope avant chargement | scope > feature, doute budget |
| `python3 _APP/sync-all-bidirectional-links.py` | sync liens bidir complet | maintenance mensuelle |

### Skills invocables
| Skill | Quand |
|---|---|
| `/new-feature <projet> <N-slug>` | créer une feature |
| `/new-project <nom>` | créer un projet |
| `/capture [<projet> <N-slug>]` | fin de session |
| `/load-feature <projet> <N-slug>` | charger contexte feature |
| `/load-project <slug>` | charger contexte projet |
| `/graphify` | lancer graphify incrémental |
| `schema-drawio-propre` | créer/modifier diagramme draw.io |

### Règles FK (source : SCHEMA.md + check-vault-integrity.py)
- FK = **toujours pluriel array** : `clients:` / `projets:` / `features:` — jamais singulier
- Liens = **toujours quotés** : `"[[slug]]"` — jamais `[[slug]]` nu
- Feature memory → `features:` **uniquement** (jamais `projets:` — pollution downlinks projet)
- Types = vocabulaire fermé `VALID_TYPES` dans `check-vault-integrity.py` — source unique absolue
