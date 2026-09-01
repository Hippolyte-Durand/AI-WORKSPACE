<#
.SYNOPSIS
Crée un ticket helpdesk PHYT'S depuis le gabarit Template_Ticket.

.DESCRIPTION
Écrit la note de ticket à la racine de TICKETS/ et son dossier de pièces à
côté. La note est à la racine et non dans le dossier : le kanban rattache une
carte au board le plus proche, et un .md rangé dans un sous-dossier devient la
tâche de ce dossier — sans carte parente pour l'afficher, il reste invisible.

.EXAMPLE
.\New-Ticket.ps1 -Titre "Besoin d'un poste Qualité" -Numero 3826

.EXAMPLE
.\New-Ticket.ps1 -Titre "Imprimante hors ligne" -Numero 3901 -Statut 'À faire' -Priorite Haute -Demandeur "audrey.berthereau" -Service Production -Commit
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory)][string]$Titre,
  [Parameter(Mandatory)][string]$Numero,
  [string]$Statut = 'En cours',
  [string]$Priorite = 'Moyenne',
  [string]$Demandeur = '',
  [string]$Service = '',
  [switch]$Commit
)

. (Join-Path $PSScriptRoot '_phyts.ps1')

Assert-Valeur $Statut   $STATUTS   'Statut'
Assert-Valeur $Priorite $PRIORITES 'Priorité'

$vault   = Get-Vault
$tickets = Join-Path $vault 'TICKETS'
$gabarit = Join-Path $vault 'TEMPLATES\Template_Ticket'

$nom = "$Titre ($Numero)"
Assert-NomFichier $nom

$note    = Join-Path $tickets "$nom.md"
$dossier = Join-Path $tickets $nom

$corps = Get-CorpsGabarit (Join-Path $gabarit 'Incident.md')
if (-not $corps) {
  $corps = @'
## Constat
Ce qui est observé, par qui, depuis quand.

## Impact
Postes, services et utilisateurs touchés.

## Diagnostic
Ce qui a été vérifié, et ce que ça a donné.

## Résolution
Actions appliquées. Une règle d'infra modifiée porte l'identifiant de ce ticket.
'@
}

$extra = @{}
if ($Demandeur) { $extra['demandeur'] = $Demandeur }
if ($Service)   { $extra['service']   = $Service }

$fm = New-Frontmatter -Type 'Ticket' -Statut $Statut -Priorite $Priorite `
                      -DateDebut (Get-Date -Format 'yyyy-MM-dd') -Extra $extra

Write-Note $note "$fm`n`n# $nom`n`n$corps`n"

# Le dossier de pièces porte le nom de la note sans extension : c'est à ça que
# le board reconnaît le dossier de travail d'une carte. Git ne versionne pas un
# dossier vide, le README du gabarit lui donne un contenu.
$readme = Get-CorpsGabarit (Join-Path $gabarit 'doc\README.md')
if (-not $readme) {
  $readme = "Documents fournis ou produits : exports Excel, captures, journaux, devis.`nNom de fichier en kebab-case, daté quand il s'agit d'un export."
}
Write-Note (Join-Path $dossier 'README.md') "# Pièces du ticket`n`n$readme`n"

$reponse = Get-CorpsGabarit (Join-Path $gabarit 'Reply.md')
if (-not $reponse) { $reponse = "À copier dans le mail ou le ticket d'origine." }
Write-Note (Join-Path $dossier 'Reply.md') "# Réponse au demandeur`n`n$reponse`n"

Show-Cree @($note, (Join-Path $dossier 'README.md'), (Join-Path $dossier 'Reply.md'))

if ($Commit) { Invoke-Commit $tickets "feat(ticket): $Numero — $Titre" }
