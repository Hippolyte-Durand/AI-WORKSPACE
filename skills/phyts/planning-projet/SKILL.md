---
name: planning-projet
description: Transforme une idée de projet PHYT'S en notes Projet / Feature / Tâche dans PROJETS/, visibles sur le board Kanban. Déclencheurs "nouveau projet", "crée-moi un projet", "organise ça en projet", ou toute demande de découper une idée en features et tâches suivies.
---

# Planning projet PHYT'S

Une idée brute devient un design validé, puis un dossier de projet dans
`PROJETS/` : une note `Projet`, ses `Feature`, leurs `Tâche`. Le brief et le
plan vivent dans le corps de la note projet elle-même, pas dans un document
séparé rangé ailleurs.

Source : $ARGUMENTS

**Sous-skill obligatoire :** `idea-refine` pour l'étape 1. Sa validation
explicite ne se saute pas — rien ne s'écrit dans `PROJETS/` avant un oui.

## Portée
Artefacts de suivi uniquement. Si le design validé demande du code, c'est un
travail séparé dans le dépôt du projet — ce skill s'arrête aux notes.

## Quand l'utiliser
- Une idée neuve à organiser en projet suivi.
- Une demande de découpage en « features et tâches ».

Pas pour : modifier un projet existant (éditer ses notes directement), ni une
tâche de code sans besoin de suivi.

## Emplacement

`~/Documents/PHYTS/PROJETS/<Nom-Projet>/` — un dossier par projet, **et un
dépôt git par projet** (le board lit une ref, pas l'arbre de travail).

```
PROJETS/<Nom-Projet>/
├── .kanban-board.json              ← fait du dossier un board
├── <Nom Projet>.md                 ← la note Projet : brief + plan
├── Related/
│   └── <Nom Feature>/
│       ├── <Nom Feature>.md        ← la Feature
│       └── <Code> - <Nom Tâche>.md ← les Tâches (A1, A2, B1…)
└── docs/, src/                     ← spec technique et code, s'il y en a
```

`<Code>` est un identifiant court (`A1`, `B2`) : une lettre par feature, un
numéro par tâche. Il regroupe visuellement les tâches quand le dossier est
trié par nom.

`.kanban-board.json` du projet :

```json
{
  "name": "<Nom Projet>",
  "description": "<une phrase : ce que le projet fait>"
}
```

## Process

1. **Brainstormer** (`idea-refine`) : questions de cadrage, approche proposée,
   design présenté, validation explicite. Pas de validation, pas d'étape 2.
2. **Nommer le projet** — syntagme nominal court, devient le nom du dossier
   (`Support-Mail-Assistant`) et le titre de la note (`Support Mail Assistant`).
3. **Créer le dossier et son dépôt** : `git init`, puis `.kanban-board.json`.
4. **Écrire la note Projet** `<Nom Projet>.md` — frontmatter et corps ci-dessous.
   Elle porte le brief et le plan en entier, pas un lien vers un doc externe.
5. **Une note par Feature** dans `Related/<Nom Feature>/<Nom Feature>.md`,
   `parent` vide et `epic: <Nom Projet>`.
6. **Une note par Tâche** dans le dossier de sa feature,
   `<Code> - <Nom Tâche>.md`, `parent: "<Nom Feature>"`.
7. **Commit et push sur `main`.** Tant que ce n'est pas poussé, le projet
   n'existe sur le board pour personne.
8. **Tenir les statuts à jour** pendant l'implémentation — voir ci-dessous.

## Tenir les statuts à jour

La portée reste le suivi, mais les notes doivent refléter le réel au fur et à
mesure que le travail avance ailleurs (code, spec, terrain) :

- Tâche finie → sa note : `statut: Terminé`, `date_fin: <aujourd'hui>`.
- Toutes les tâches d'une feature `Terminé` → la feature : `statut: Terminé`,
  `date_fin: <aujourd'hui>`.
- Toutes les features `Terminé` → le projet : `statut: Terminé`, `date_fin`.
- Travail qui démarre sur un `À faire` → `statut: En cours`, et `date_debut`
  s'il est encore vide, **avant** d'y toucher.

Mise à jour dans le même tour que la tâche réellement finie, pas groupée à la
fin — puis commit et push, sinon le changement n'est visible de personne.

## Frontmatter

Même schéma pour les trois niveaux, champs présents même vides :

```yaml
---
type: Projet          # Projet | Feature | Tache
statut: À faire       # Backlog | À faire | En cours | Bloqué | Revue | Terminé
priorite: Moyenne     # Critique | Haute | Moyenne | Basse — jamais vide
epic:                 # le nom du projet, pour Projet et Feature
date_debut:
date_fin:
date_echeance:        # AAAA-MM-JJ
parent:               # vide pour Projet et Feature ; nom de la feature pour une Tâche
documentation:        # chemin d'une spec versionnée, sinon vide
runbook:
---
```

- `statut` : tout ce qui est neuf est `À faire`, sauf si déjà fait. Une valeur
  hors vocabulaire n'efface pas la carte, elle la range en **Backlog** — ce qui
  se voit mais se lit mal. `Résolu`, `À traiter`, `En attente` ne sont pas
  reconnus : écrire `Terminé`, `À faire`, `Bloqué`.
- `priorite` : choisie pour de vrai — `Haute` pour ce qui bloque d'autres
  features ou tâches, `Moyenne` par défaut, `Basse` pour finitions et doc.
- `parent` : **c'est lui qui distingue une feature d'une tâche.** Une carte sans
  `parent` est une feature, une carte avec `parent` est une tâche de cette
  feature. Nom simple entre guillemets, pas de lien.
- `type` et `project` sont dérivés à la lecture du board ; les écrire reste utile
  pour qui lit le fichier, mais ne pilote rien.
- `documentation` / `runbook` : vides sauf chemin réel à pointer.

## Corps de la note Projet

Le corps de la note Projet **est** le brief et le plan — l'écrire, pas le
résumer avec un lien :

```markdown
<Un paragraphe : ce que c'est, et pourquoi.>

## Contexte
<Pourquoi ce projet existe maintenant.>

## Objectifs
- <objectif 1>
- <objectif 2>

## Non-objectifs
- <explicitement hors périmètre v1>

## Approche
<Architecture et approche retenues au brainstorming, quelques paragraphes.>

## Découpage Features → Tâches
- **<Feature 1>** — <sa raison d'être en une ligne>
  - <Code> <tâche 1>
  - <Code> <tâche 2>
- **<Feature 2>** — <sa raison d'être en une ligne>
```

Les corps des notes Feature et Tâche restent courts (1 à 3 lignes : ce que ça
couvre). Le détail vit dans le plan de la note Projet, pas dupliqué par note.

## Erreurs courantes
- Créer les notes avant la validation du design — le oui d'abord.
- Oublier `.kanban-board.json` : le dossier ne devient pas un board, aucune
  carte n'apparaît.
- Écrire les notes sans commiter ni pousser : le board lit une ref, pas le
  disque. Un projet non poussé n'existe pas.
- `priorite` vide — c'est elle qui pilote tri et couleur du board.
- `parent` sur une feature, ou absent sur une tâche : la hiérarchie du board
  se lit là, et nulle part ailleurs.
- Mettre le brief dans un `docs/` séparé et n'en laisser qu'un lien dans la
  note Projet — le brief appartient au corps de la note.
