# New-Projet.ps1

Crée le squelette d'un projet du vault : dossier, marqueur de board, note
Projet et `Related/`.

## Paramètres

| Paramètre | Obligatoire | Défaut | Rôle |
|---|---|---|---|
| `-Nom` | oui | — | Nom du projet. Sert de nom de dossier, de nom de note et d'identifiant de carte. |
| `-Description` | oui | — | Une ligne. Reprise dans `.kanban-board.json` et en tête de la note. |
| `-Statut` | non | `À faire` | Colonne du board. |
| `-Priorite` | non | `Moyenne` | `Haute` si le projet en bloque d'autres. |
| `-Git` | non | — | `git init -b main` dans le dossier, plus un `.gitignore` minimal. |
| `-Commit` | non | — | `git add -A` puis commit. |

## Ce qu'il écrit

```
PROJETS/<Nom>/
├── .kanban-board.json     name + description : c'est ce fichier qui fait le board
├── <Nom>.md               note Projet : frontmatter + plan à compléter
└── Related/               vide, prêt pour les Features
```

La note porte `type: Projet`, `date_debut` au jour de création, et un `parent`
**vide** : une carte sans parent est une feature aux yeux du board, une carte
avec parent est une tâche. Le corps reprend le plan attendu — Contexte,
Objectifs, Non-objectifs, Approche, Découpage — à remplir.

## `-Git`, et pourquoi ça compte

Le board ne lit que des refs git. Un projet hors dépôt n'apparaît nulle part,
quel que soit son frontmatter. `-Git` initialise le dépôt sur `main` et
rappelle le remote attendu :
`DURAND-Hippolyte-PHYTS/PHYTS-<Nom-avec-des-tirets>`. La création du dépôt
distant et le premier push restent manuels.

`PROJETS/` lui-même n'est pas versionné : chaque projet est un dépôt
indépendant, et on commite depuis son dossier.

## Exemples

```powershell
& "$B\New-Projet\New-Projet.ps1" -Nom "Audit Sauvegardes" `
    -Description "Vérifier la couverture des sauvegardes serveurs." `
    -Priorite Haute -Git -Commit
```

## Erreurs possibles

| Message | Cause |
|---|---|
| `Existe déjà : …` | Un projet porte ce nom. Le script n'écrase jamais. |
| `Statut « … » hors vocabulaire` | Voir la liste dans [README.md](../README.md). |
| `les caractères \ / : * ? " < > \| sont interdits` | Le nom sert de nom de dossier et de fichier. |

## Après

Ajouter les Features avec [New-Feature.ps1](../New-Feature/README.md), puis les
tâches avec [New-Tache.ps1](../New-Tache/README.md). Le script pose la structure ;
le brief et le découpage demandent du jugement — c'est le rôle de la skill
`planning-vault-project`, qui part alors d'une note déjà bien formée.
