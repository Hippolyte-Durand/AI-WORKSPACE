# New-Ticket.ps1

Crée un ticket helpdesk à partir du gabarit `TEMPLATES/Template_Ticket/`.

## Paramètres

| Paramètre | Obligatoire | Défaut | Rôle |
|---|---|---|---|
| `-Titre` | oui | — | Intitulé court et cherchable, sans le numéro. |
| `-Numero` | oui | — | Numéro GLPI. Sans lui, le ticket ne se recroise avec rien — le demander plutôt que l'inventer. |
| `-Statut` | non | `En cours` | Colonne du board. |
| `-Priorite` | non | `Moyenne` | Fixée par l'impact réel, pas par le ton du mail. |
| `-Demandeur` | non | — | Ajouté au frontmatter s'il est fourni. |
| `-Service` | non | — | Idem. |
| `-Commit` | non | — | `git add -A` puis commit dans `TICKETS/`. |

## Ce qu'il écrit

```
TICKETS/
├── <Titre> (<n°>).md          la carte : frontmatter + les 4 sections du gabarit
└── <Titre> (<n°>)/            les pièces
    ├── README.md              rappel de nommage (kebab-case, daté)
    └── Reply.md               réponse au demandeur
```

Le frontmatter porte `type: Ticket`, le statut, la priorité, `date_debut` au
jour de création, et `demandeur`/`service` quand ils sont passés.

Les sections du corps sont lues dans `TEMPLATES/Template_Ticket/Incident.md` à
chaque exécution : modifier le gabarit change les tickets suivants, sans
toucher au script. Si le gabarit est absent, une copie de secours intégrée
prend le relais.

## Pourquoi la note est à la racine et non dans le dossier

Le kanban rattache une carte au board marqué le plus proche d'elle, et déduit
la hiérarchie du champ `parent`, à défaut du dossier porteur. Un `.md` rangé
dans `TICKETS/<Titre> (<n°>)/` devient donc la **tâche** d'une carte nommée
`<Titre> (<n°>)` — carte qui n'existe pas. La tâche n'a alors aucun parent
pour l'afficher et n'apparaît sur aucune colonne. C'est le cas des tickets
3581 et 3843, invisibles pour cette raison.

Le dossier de pièces porte le nom de la note sans extension : le serveur y
reconnaît le dossier de travail de la carte et l'expose depuis le panneau de
détail.

## Exemples

```powershell
& "$B\New-Ticket.ps1" -Titre "Besoin d'un poste Qualité" -Numero 3826

& "$B\New-Ticket.ps1" -Titre "Imprimante hors ligne" -Numero 3901 `
    -Statut 'À faire' -Priorite Haute `
    -Demandeur "audrey.berthereau" -Service Production -Commit
```

## Erreurs possibles

| Message | Cause |
|---|---|
| `Existe déjà : …` | Un ticket porte ce titre et ce numéro. Le script n'écrase jamais. |
| `Statut « … » hors vocabulaire` | Voir la liste dans [README.md](README.md). `Résolu`, `À traiter`, `En attente` ne sont pas reconnus. |
| `les caractères \ / : * ? " < > \| sont interdits` | Le titre sert de nom de fichier, donc d'identifiant de carte. |
| `Vault introuvable` | Définir `PHYTS_VAULT`, ou vérifier `~/Documents/PHYTS`. |

## Après

Le ticket n'apparaît sur le board qu'une fois **commité** — le serveur lit une
ref git, jamais l'arbre de travail. Instruire ensuite le Constat, l'Impact et
le Diagnostic : c'est la partie qui demande du jugement, et la skill
`support-ticket` est faite pour ça.
