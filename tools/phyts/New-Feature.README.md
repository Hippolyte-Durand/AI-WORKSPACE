# New-Feature.ps1

Crée une Feature dans un projet existant, avec son propre board.

## Paramètres

| Paramètre | Obligatoire | Défaut | Rôle |
|---|---|---|---|
| `-Projet` | oui | — | Nom du dossier sous `PROJETS/`. Doit exister. |
| `-Nom` | oui | — | Nom de la Feature. Sert de nom de dossier, de note et d'identifiant de carte — c'est ce nom que les tâches citeront dans `parent`. |
| `-Description` | oui | — | Une à trois lignes. Reprise dans `.kanban-board.json` et dans le corps. |
| `-Statut` | non | `À faire` | Colonne du board. |
| `-Priorite` | non | `Moyenne` | `Haute` si la Feature en bloque d'autres. |
| `-Commit` | non | — | `git add -A` puis commit dans le dépôt du projet. |

## Ce qu'il écrit

```
PROJETS/<Projet>/Related/<Nom>/
├── .kanban-board.json     fait de ce dossier un board
└── <Nom>.md               note Feature : frontmatter + description
```

Le `parent` est laissé **vide**, volontairement. La hiérarchie du board n'a
qu'un seul niveau : une carte sans parent est une feature, une carte avec
parent est une tâche de la carte portant cet identifiant. Il n'y a pas de
tâche de tâche. Pour que la note Feature soit la carte racine de son board et
reçoive ses tâches, elle ne doit donc citer aucun parent.

## Conséquence du board dédié

Une carte appartient au board marqué **le plus proche** d'elle. Poser un
`.kanban-board.json` dans le dossier de la Feature y attire la Feature et ses
tâches : elles quittent le board du projet, qui ne les compte plus. C'est ce
qui évite le double comptage, et c'est aussi pourquoi le board du projet
n'affiche plus que la note Projet.

Pour garder les Features sur le board du projet, ne pas utiliser ce script :
créer la note à la main sans marqueur, avec `parent: "<Nom du projet>"`.

## Exemples

```powershell
& "$B\New-Feature.ps1" -Projet "Audit Sauvegardes" `
    -Nom "Inventaire des jobs" `
    -Description "Lister les jobs de sauvegarde existants." -Commit
```

## Erreurs possibles

| Message | Cause |
|---|---|
| `Projet introuvable : …` | Le dossier n'existe pas sous `PROJETS/`. Le créer avec [New-Projet.ps1](New-Projet.README.md). |
| `Existe déjà : …` | Une Feature porte ce nom dans ce projet. |
| `Statut « … » hors vocabulaire` | Voir la liste dans [README.md](README.md). |

## Après

Le script affiche la commande `New-Tache.ps1` prête à copier, avec le projet
et la feature déjà renseignés.
