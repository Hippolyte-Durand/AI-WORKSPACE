---
name: init-repo
description: Génère un CLAUDE.md racine de repo — règles vault↔repo + table features→branches auto-remplie depuis le vault
disable-model-invocation: true
---

Projet : $ARGUMENTS
(format : `<projet-slug>` ex: `agentics-obsidian-os`)

## Mission

Générer le `CLAUDE.md` à placer à la racine du repo git du projet. Ce fichier dit à Claude Code (et aux humains) quoi mettre dans le repo vs dans le vault, et mappe chaque feature vault à sa branche git.

Si le cockpit projet a `repo:` renseigné avec un chemin local → écrire directement `CLAUDE.md` dans ce dossier. Sinon → afficher le contenu pour copie manuelle.

## Inputs

| Fichier | Couche | Sections | Pourquoi |
|---|---|---|---|
| `DATA/1-Projects/<area>/<slug>/<slug>.md` | L4 | `repo:`, `clients:`, `area:`, `statut:` | URL/chemin repo + client FK |
| `DATA/1-Projects/<area>/<slug>/memory/brief.md` | L4 | Objectif | résumé 1 phrase pour header CLAUDE.md |
| `DATA/1-Projects/<area>/<slug>/features/*/` | L4 | dossiers présents | liste features → table branches |
| `DATA/1-Projects/<area>/<slug>/features/<N-slug>/<N-slug>.md` | L4 | `description:` | libellé court de la feature |

## Process

1. Parser `$ARGUMENTS` → `<projet-slug>`. Si manquant → escalade.
2. Localiser le projet : `find DATA/1-Projects -type d -name "<projet-slug>"` → chemin `<projet-path>`.
3. Lire le cockpit `<projet-path>/<slug>.md` → extraire `repo:`, `clients:`, `description:`.
4. Lire `<projet-path>/memory/brief.md` → extraire objectif (champ **🎯 Objectif**).
5. Lister les features : `ls <projet-path>/features/` → liste ordonnée `<N-slug>`.
6. Pour chaque feature : lire `features/<N-slug>/<N-slug>.md` → extraire `description:`.
7. Résoudre destination :
   - `repo:` est un chemin local absolu/relatif existant → destination = `<repo-path>/CLAUDE.md`
   - `repo:` est une URL ou vide → destination = affichage console pour copie manuelle
8. Générer le contenu `CLAUDE.md` (voir template ci-dessous).
9. Écrire ou afficher selon destination.
10. Confirmer : chemin écrit OU rappel "colle dans la racine de ton repo".

## Template CLAUDE.md généré

```markdown
# CLAUDE.md — <projet-slug>

> <description 1 phrase depuis brief.md>

Vault projet : `DATA/1-Projects/<area>/<slug>/`  
Client : [[<client-slug>]] _(retirer si pas de client)_  
Repo   : <repo url/path>

---

## Vault ↔ Repo — qui met quoi où

| Information | Destination |
|-------------|-------------|
| Pourquoi le projet / contexte client | vault `memory/brief.md` |
| Décisions de scope, priorités, arbitrages | vault `memory/decisions.md` |
| Blocages, log de travail, apprentissages | vault `memory/blocages.md` · `sessions.md` · `apprentissages.md` |
| Setup, stack, comment lancer / déployer | repo `README.md` |
| Décisions techniques (archi, lib, pattern) | repo `docs/adr/<slug>.md` (créer à la demande) |
| Feature — goal + critères de livraison | vault `features/<N-slug>/memory/brief.md` |
| Feature — code d'implémentation | branche `feature/<N-slug>` (même slug que vault) |

**Règle d'or** : si l'info reste utile après suppression du repo → vault. Si elle meurt avec le code → repo.

---

## Features → Branches

| # | Slug | Description | Branche git | Brief vault |
|---|------|-------------|-------------|-------------|
| 01 | 01-<slug> | <description> | `feature/01-<slug>` | `features/01-<slug>/memory/brief.md` |
| … | … | … | … | … |

Convention nouvelle feature :
1. `/new-feature <projet-slug> <NN-slug>` dans le vault en premier
2. `git checkout -b feature/<NN-slug>` dans le repo
3. PR title : `[<NN-slug>] titre`
4. Commit scope : `feat(<NN-slug>): message`

---

## Conventions repo

- **Branches** : `feature/<N-slug>` · `fix/<N-slug>-<desc>` · `chore/<desc>`
- **Commits** : `<type>(<N-slug>): message` — types : feat / fix / chore / docs / refactor
- **PR** : titre `[<N-slug>] <ce qui change>` · body → lien brief vault + résumé technique
- **ADR** : `docs/adr/<YYYY-MM-DD>-<slug>.md` — décisions techniques avec contexte et alternatives
- **Jamais dans le repo** : contexte client, notes de session, décisions de scope → vault

---

## Checklist nouvelle feature

- [ ] Brief vault rempli (`features/<N-slug>/memory/brief.md`)
- [ ] Branche créée depuis main (`feature/<N-slug>`)
- [ ] PR liée au brief vault (mention dans description)
- [ ] ADR créé si décision technique structurante
- [ ] Brief vault mis à jour si scope a changé en cours de dev
```

## Outputs

- `CLAUDE.md` écrit dans le repo (si `repo:` local) **OU** contenu affiché pour copie
- Rappel : si `repo:` était vide dans le cockpit → demander l'URL/chemin et mettre à jour le frontmatter cockpit

## Escalade

- Projet introuvable → demander l'area ou le chemin exact.
- `repo:` vide ET chemin non fourni → générer quand même le CLAUDE.md, afficher "Ajoute `repo: <chemin>` dans le cockpit projet après."
- Feature sans `description:` dans son cockpit → mettre `(à compléter)` dans la table, ne pas bloquer.
