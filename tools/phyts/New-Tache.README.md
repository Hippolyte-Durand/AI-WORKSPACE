# New-Tache.ps1

Crée une Tâche dans une Feature existante.

## Paramètres

| Paramètre | Obligatoire | Défaut | Rôle |
|---|---|---|---|
| `-Projet` | oui | — | Nom du dossier sous `PROJETS/`. |
| `-Feature` | oui | — | Nom de la Feature. Doit exister, et sa valeur est recopiée telle quelle dans `parent`. |
| `-Code` | oui | — | Identifiant court : `A1`, `B2`, `C3`. La lettre groupe les tâches par Feature, le chiffre donne l'ordre. |
| `-Nom` | oui | — | Intitulé de la tâche, sans le code. |
| `-Description` | oui | — | Une à trois lignes. Le détail vit dans le plan du Projet, pas ici. |
| `-Statut` | non | `À faire` | Colonne du board. |
| `-Priorite` | non | `Moyenne` | |
| `-Commit` | non | — | `git add -A` puis commit dans le dépôt du projet. |

## Ce qu'il écrit

```
PROJETS/<Projet>/Related/<Feature>/<Code> - <Nom>.md
```

Frontmatter `type: Tache` et `parent: "<Feature>"`.

## Le champ qui décide de tout

`parent` porte le **nom nu** de la Feature, jamais un `[[wikilink]]`. Le
serveur compare `parent` à l'identifiant d'une carte — le nom de fichier sans
extension — par égalité stricte. `"[[Client Graph API]]"` ne correspond à
aucune carte : la tâche existe, elle est lue, elle a un parent, mais aucune
carte ne la revendique et elle n'apparaît sur aucune colonne. Silencieusement.
C'est le défaut qui rendait les 19 tâches de Support-Mail-Assistant invisibles.

Le script écrit toujours la bonne forme, c'est sa raison d'être.

## Le code n'est pas décoratif

Il préfixe le nom de fichier, donc l'identifiant de la carte, et le tri du
board se fait sur cet identifiant. `A1`, `A2`, `B1` gardent les tâches d'une
même Feature groupées et dans l'ordre ; sans code, elles se rangent par ordre
alphabétique de leur intitulé.

## Exemples

```powershell
& "$B\New-Tache.ps1" -Projet "Support-Mail-Assistant" `
    -Feature "Client Graph API" -Code B1 -Nom "listSupportMessages" `
    -Description "Lecture des mails de l'inbox support via Graph API." -Commit
```

## Erreurs possibles

| Message | Cause |
|---|---|
| `Feature introuvable : …` | Le dossier n'existe pas sous `Related/`. La créer avec [New-Feature.ps1](New-Feature.README.md). |
| `Existe déjà : …` | Ce code et ce nom sont déjà pris. |
| `les caractères \ / : * ? " < > \| sont interdits` | La vérification porte sur `<Code> - <Nom>` assemblé. |

## Après

Tenir le statut à jour dans le même geste que le travail : `En cours` au
démarrage, `Terminé` avec `date_fin` à la fin. Un board qui montre tout en
`À faire` pendant que le travail avance ne sert plus à rien.
