---
name: new-project
description: Crée un projet (dossier + cockpit + brief + 5 fichiers memory)
disable-model-invocation: true
---

Crée un projet nommé : $ARGUMENTS

> Source unique de vérité. Suis ces étapes **dans l'ordre**. Templates = `_TEMPLATES/*.md` individuels (voir `_TEMPLATES/00-README.md`). Ne recopie jamais de contenu du repo code dans le vault.

## Inputs
| Fichier | Couche | Sections | Pourquoi |
|---|---|---|---|
| `_TEMPLATES/{projet,memory-*,contact,infra,machine}.md` | L3 | tout | structure des entités à instancier |
| `/new-client` (commande sœur) | L2 | flux complet | déléguée si le client du projet n'existe pas encore (0.2) |
| `DATA/3-Resources/{Clients,Contacts}/` | L4 | racine | vérifier l'existant avant de lier/créer (0.2, 0.3) |
| `SCHEMA.md` | L3 | `projet`, `contact` | champs valides + `description` obligatoire |
| `DOCTRINE.md` | L3 | `#foyer-unique`, `#memory`, `#view-mocs` | rangement par TYPE + routage memory + règles UX views |
| `$ARGUMENTS` + réponses champs | L4 | — | nom/area/repo/client du projet |
| `.obsidian/plugins/obsidian-icon-folder/data.json` | L4 | racine | à éditer (icônes dossiers créés) |

## 0. Onboarding interactif — vérifier AVANT de créer
> Flux séquentiel. **Aucune écriture des fichiers du projet (steps 1-6) avant le récap 0.7 confirmé.** Exception : la création d'un client absent est **déléguée à `/new-client`** en 0.2 — c'est un flux commit indépendant, avec sa propre confirmation. À chaque ressource : vérifier l'existant → **lier** si présent, **créer/déléguer** si absent. Une question à la fois, ne redemande pas ce qui est déductible de `$ARGUMENTS`.

### 0.1 Identité
- **Slug** = nom en kebab-case (`Migration Sage` → `migration-sage`). Évident depuis `$ARGUMENTS`, ne le redemande pas. Pas de trigramme (réservé aux clients).
- **Area** ∈ `{Perso, Pro, Ecole, Business, Certifs}` (Capitalisé, valeur fermée). Déduire si évident, sinon **demander**.
- **description** = 1 phrase, **obligatoire** (`✅ Req` dans `SCHEMA.md` — source de vérité IA). Demander si non déductible.
- **repo** = chemin local ou URL git (vide si pas de code).

### 0.2 Client (optionnel)
Demander si projet client. Si oui :
1. Vérifier : `ls DATA/3-Resources/Clients/` + fuzzy-match nom → slug existant (`iotech`, `xefi-cahors`…).
2. **Présent** → retenir `clients: ["[[<slug>]]"]`.
3. **Absent** → **déléguer à `/new-client <nom>`** (crée l'entité `type: entreprise` + memory + contact principal), puis reprendre avec le slug obtenu. Ne crée pas de stub client inline.

### 0.3 Contacts liés (optionnel)
Demander les noms. Pour chacun :
1. Fuzzy-match `DATA/3-Resources/Contacts/*.md` (`Tom` → `Joseph-Tom.md`) pour éviter un doublon.
2. **Présent** → retenir pour le `contacts: ["[[<nom>]]"]` du cockpit projet ; si le contact n'a pas déjà `entreprises: ["[[<client>]]"]` et qu'un client est connu, l'ajouter.
3. **Absent** → **créer inline** depuis `_TEMPLATES/contact.md` : `type: contact`, `nom`, `description`, `entreprises: ["[[<client>]]"]` si client connu, + `email`/`phone`/`poste` si fournis.
> Les contacts remontent dans la §Contacts du cockpit projet via le champ `contacts:` (et côté entreprise si projet client). Fonctionne donc **même sans client** (projet Perso).

### 0.4 Brief projet
Collecter **Contexte / Objectif / Périmètre / Livrables / Contraintes / Critères de succès**. Partiel OK → `TODO` sur ce qui manque. Destination : `memory/brief.md` du projet (step 2).

### 0.5 Brief client — ventilation (si projet client)
L'info **niveau-relation** (contexte client, contraintes client, interlocuteurs, historique) va dans `DATA/3-Resources/Clients/<client>/memory/brief.md`, **jamais** dans le brief projet. Compléter aussi le champ `projets: ["[[<slug>]]"]` de ce brief client (routing bidirectionnel brief client ↔ brief projet).

### 0.6 Infra (projet réseau seulement)
Demander si le projet a une infra/machines. Si oui → exécuter le `## 4. Infra` (amorce `Infra/<slug>-infra.md` + machines). Sinon skip.

### 0.7 Récap & confirm
Afficher un tableau **Lié (existant)** vs **À créer** (client délégué / contacts inline / infra) + le frontmatter cockpit résolu. **Attendre OK** avant d'exécuter les steps 1-6.

## 1. Cockpit `DATA/1-Projects/<slug>/<slug>.md`
Depuis `_TEMPLATES/projet.md`. **Nommé par le projet** (jamais `Home-<slug>`). Frontmatter (noms de champs = `SCHEMA.md`) : `type: projet`, `description: "<1 phrase>"` (**Req**), `area: <Area>`, `statut: en cours`, `créé: <date>`, `maj: <date>`, `repo:`, et **arrays** `clients: ["[[<slug>]]"]` / `parents: ["[[<parent>]]"]` si applicable (jamais les singuliers `client:`/`parent:`) + `contacts: ["[[<nom>]]", …]` (0.3, surface la §Contacts du cockpit — marche même sans client). Titre H1. Breadcrumb `⬆️ [[HOME]]`. Remplacer **tous** les `<slug>` (ligne 📂 Code, filtres, tâches, infra). Si pas de code : retirer la ligne 📂 Code.

## 2. Mémoire `memory/{brief,decisions,apprentissages,blocages,sessions,evals}.md`
Depuis `_TEMPLATES/memory-*.md`. **Noms sans préfixe**. Pour chacun : FK `projets: ["[[<slug>]]"]` (array obligatoire), `maj: <date>`, titre H1. Remplir `brief.md` (Contexte/Objectif/Périmètre/Livrables/Contraintes/Critères). Les 5 autres = structure OK, contenu vide day 1.

**Routing brief** : si projet client (`clients:` renseigné dans le cockpit), ajouter aussi `clients: ["[[<client-slug>]]"]` dans le frontmatter du `brief.md`. Cela permet la navigation directe brief projet → brief client sans passer par le cockpit.

## 3. Arbo — LAZY, zéro scaffold spéculatif
Day 1 = **cockpit + `memory/` uniquement**. Ne crée AUCUN dossier vide « au cas où » (`assets/`, `maquettes/`, `draft/`, `doc/`, `kanban/`…). Chaque dossier naît au moment d'y écrire son premier fichier (mkdir juste-à-temps).
**Foyer par TYPE, pas par projet (doctrine) :**
- Savoir réutilisable (`concept`/`outil`/`topic`/`procedure`) → `DATA/3-Resources/KB/{Concepts,Outils,Topics,Procedures}/`, rattaché au projet via `related: - "[[<slug>]]"` (jamais `projet:`). **Pas de `doc/` sous le projet.**
- Info purement projet (non réutilisable) → prose dans `brief.md`, pas de note typée isolée.
- Procédures opérationnelles propres au projet (runbook) → `runbook/` (créé à la demande), type `procedure`, FK `projet:`.
- **Le code vit dans son repo** (prop `repo:`), PAS dans le vault.

## 4. Infra (projets réseau uniquement) — foyer unique `3-Resources/Infra/`
Machines et notes infra vivent **toutes** dans `DATA/3-Resources/Infra/` (plat), **jamais** sous le projet ni le client. `Infra/<slug>-infra.md` depuis `_TEMPLATES/infra.md` + `Infra/<hostname>.md` depuis `_TEMPLATES/machine.md` (**machine seule, NIC embarquées** : `type: machine`, `nic1_ip`/`nic1_reseau`/… ; multi-NIC = `nic2_*`). FK (**arrays**, cf. `SCHEMA.md#machine`) : `projets: ["[[<slug>]]"]` et/ou `clients: ["[[<client>]]"]` (une machine cliente porte les deux). Jamais les singuliers `projet:`/`client:` — le template `projet.md` §Infra filtre `projets.contains(this.asLink())`, donc un singulier ne remonte pas. Les vues (`Machines.base`, vue infra projet) regroupent par propriété — le chemin ne compte pas.

## 5. Icônes de dossier (obsidian-icon-folder)
Ajouter à la **racine** de `.obsidian/plugins/obsidian-icon-folder/data.json` (à côté de `settings`) **uniquement les entrées des dossiers qui existent vraiment** (day 1 = cockpit, memory). ⚠️ **Valeur = objet `{"iconName": ...}`**, PAS une string. JSON valide. Ajoute l'icône d'un dossier (`runbook`, `infra`…) le jour où tu le crées, pas avant.
```json
"DATA/1-Projects/<slug>": {"iconName": "LiFolderClosed"},
"DATA/1-Projects/<slug>/memory": {"iconName": "LiBrain"},
"DATA/1-Projects/<slug>/<slug>.md": {"iconName": "LiHome"}
```

## 6. Vérifier & confirmer
- **Rien** à ajouter dans `HOME.md` : `Home-Projets.base` liste par `area` automatiquement (filtre `statut == "en cours"`).
- Supprimer les `.DS_Store` créés.
- `python3 _APP/sync-memory-downlinks.py` → remplit les down-links cockpit↔memory (briefs/decisions/… path-qualifiés). Obligatoire APRÈS création des fichiers memory.
- `python3 _APP/check-vault-integrity.py` → 0 type invalide, 0 FK dure orpheline attendu.
- Confirmer : chemin `DATA/1-Projects/<slug>/`, area. Proposer de démarrer par le Brief.

Commandes sœurs : `/new-certif` · `/new-client` (`.claude/commands/`).
