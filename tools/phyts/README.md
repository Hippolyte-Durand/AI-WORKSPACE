# Échafaudage du vault PHYT'S

Quatre scripts PowerShell qui créent les notes du vault à partir des gabarits.
Créer un ticket ou une tâche est une opération mécanique : un nom de fichier,
un frontmatter, un dossier. Aucune raison d'y passer par un LLM — les scripts
la font en une commande, sans jeton et sans variation d'une fois sur l'autre.

Un LLM reste utile pour ce qui demande du jugement : instruire un incident,
rédiger la réponse au demandeur, découper un projet en features. Il part alors
d'une note déjà correctement formée.

## Scripts

| Script | Crée | Doc |
|---|---|---|
| `New-Ticket.ps1` | `TICKETS/<Titre> (<n°>).md` + son dossier de pièces (`README.md`, `Reply.md`) | [New-Ticket.README.md](New-Ticket.README.md) |
| `New-Projet.ps1` | `PROJETS/<Nom>/` : note Projet, `.kanban-board.json`, `Related/` | [New-Projet.README.md](New-Projet.README.md) |
| `New-Feature.ps1` | `PROJETS/<Projet>/Related/<Feature>/` : note Feature et son board | [New-Feature.README.md](New-Feature.README.md) |
| `New-Tache.ps1` | `PROJETS/<Projet>/Related/<Feature>/<Code> - <Nom>.md` | [New-Tache.README.md](New-Tache.README.md) |

`_phyts.ps1` porte les briques communes et ne s'exécute pas seul — voir
[_phyts.README.md](_phyts.README.md). Chaque script a son README attenant :
paramètres, fichiers produits, erreurs possibles et la règle du board qu'il
applique.

## Utilisation

```powershell
$B = "$HOME\Documents\TOOLS\AI-WORKSPACE\tools\phyts"

& "$B\New-Ticket.ps1" -Titre "Imprimante hors ligne" -Numero 3901 `
    -Priorite Haute -Demandeur "audrey.berthereau" -Service Production

& "$B\New-Projet.ps1"  -Nom "Audit Sauvegardes" -Description "Couverture des sauvegardes serveurs." -Git
& "$B\New-Feature.ps1" -Projet "Audit Sauvegardes" -Nom "Inventaire des jobs" -Description "Lister les jobs existants."
& "$B\New-Tache.ps1"   -Projet "Audit Sauvegardes" -Feature "Inventaire des jobs" `
    -Code A1 -Nom "Export Veeam" -Description "Exporter la liste des jobs."
```

Options communes : `-Statut`, `-Priorite`, `-Commit`. `New-Projet.ps1` accepte
en plus `-Git` pour initialiser le dépôt.

Le vault est `~/Documents/PHYTS`, ou la valeur de `PHYTS_VAULT` si elle est
définie — c'est par là qu'on teste sur une copie jetable avant la prod.

## Vocabulaire validé

Les scripts refusent une valeur hors liste plutôt que de produire une carte
mal rangée. Une valeur inconnue n'efface pas la carte côté serveur : elle
atterrit en Backlog, ce qui se voit mais se lit mal.

- `-Statut` : `Backlog`, `À faire`, `En cours`, `Bloqué`, `Revue`, `Terminé`
- `-Priorite` : `Critique`, `Haute`, `Moyenne`, `Basse`

## Trois règles du board qu'ils appliquent pour vous

1. **Un `.md` sans `statut` n'est pas une carte.** Il n'est ni en erreur ni
   signalé, il est simplement absent du board.
2. **`parent` porte un nom nu, jamais un `[[wikilink]]`.** La comparaison avec
   l'identifiant d'une carte — le nom de fichier sans extension — est stricte.
3. **Une note de ticket va à la racine de `TICKETS/`**, son dossier de pièces à
   côté. Un `.md` rangé dans un sous-dossier devient la tâche de ce dossier, et
   sans carte parente pour l'afficher il reste invisible.

Rien n'apparaît sur le board tant que ce n'est pas **commité** : KANBAN-PHYTS
lit une ref git, jamais l'arbre de travail. `-Commit` s'en charge, le push
reste manuel.

## Encodage

Les `.ps1` sont enregistrés en UTF-8 **avec BOM**. PowerShell 5.1 — celui
installé par défaut sur Windows — lit un script sans BOM comme de l'ANSI, et
le premier accent casse l'analyse du fichier. Conserver le BOM à chaque
modification.
