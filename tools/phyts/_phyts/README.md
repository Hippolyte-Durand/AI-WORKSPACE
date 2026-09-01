# _phyts.ps1

Briques communes aux quatre scripts. Chargé par `. (Join-Path $PSScriptRoot
'_phyts.ps1')`, jamais exécuté seul. Le préfixe `_` signale cette dépendance.

## Fonctions

| Fonction | Rôle |
|---|---|
| `Get-Vault` | Racine du vault : `PHYTS_VAULT` si définie, sinon `~/Documents/PHYTS`. Échoue si le dossier n'existe pas, plutôt que d'écrire à côté. |
| `Assert-Valeur` | Refuse un statut ou une priorité hors vocabulaire. |
| `Assert-NomFichier` | Refuse `\ / : * ? " < > \|` — interdits par Windows dans un nom de fichier, qui est aussi l'identifiant de la carte. |
| `Write-Note` | Écrit un fichier, crée les dossiers manquants, **échoue si le fichier existe**. |
| `New-Frontmatter` | Assemble les 9 champs du schéma, plus les champs additionnels passés en `-Extra`. |
| `Get-CorpsGabarit` | Lit un gabarit et en retire frontmatter et titre `#` : seules les sections servent. Renvoie `$null` si le gabarit est absent ou vide. |
| `Invoke-Commit` | `git add -A` + commit, avec un avertissement si le dossier n'est pas un dépôt. |
| `Show-Cree` | Liste des chemins créés. |

## Vocabulaire

```powershell
$STATUTS   = 'Backlog', 'À faire', 'En cours', 'Bloqué', 'Revue', 'Terminé'
$PRIORITES = 'Critique', 'Haute', 'Moyenne', 'Basse'
```

Ces listes sont celles que le serveur du board sait traduire. Une valeur hors
liste n'efface pas la carte : elle atterrit en **Backlog**, ce qui se voit mais
se lit mal — d'où le refus à l'écriture plutôt qu'une surprise à la lecture.
La comparaison côté serveur ignore casse et accents : `En cours` et `En Cours`
tombent au même endroit.

## Trois choix d'implémentation

**Écriture UTF-8 sans BOM, fins de ligne LF.** `Set-Content` de PowerShell 5.1
écrirait un BOM ; `Write-Note` passe par `[IO.File]::WriteAllText` avec un
`UTF8Encoding $false`. C'est ce que git et le serveur lisent sans surprise.

**Le script lui-même est en UTF-8 *avec* BOM.** L'inverse de ce qu'il écrit,
et c'est voulu : PowerShell 5.1 lit un `.ps1` sans BOM comme de l'ANSI, et le
premier accent casse l'analyse du fichier entier. Conserver le BOM à chaque
modification.

**`Write-Note` n'écrase jamais.** Ces scripts créent ; corriger une note se
fait dans l'éditeur. Une écrasure silencieuse sur un ticket déjà instruit
coûterait bien plus qu'un message d'erreur.

## Ajouter un script

```powershell
. (Join-Path $PSScriptRoot '_phyts.ps1')

Assert-Valeur $Statut $STATUTS 'Statut'
$vault = Get-Vault
$fm = New-Frontmatter -Type 'Tache' -Statut $Statut -Priorite $Priorite -Parent $Feature
Write-Note $chemin "$fm`n`n# $titre`n`n$description`n"
Show-Cree @($chemin)
```

Passer `-Parent` avec le **nom nu** de la carte parente : la comparaison côté
serveur est stricte, un `[[wikilink]]` ne correspond à rien.
