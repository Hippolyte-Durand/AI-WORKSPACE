<#
.SYNOPSIS
Crée une Feature dans un projet du vault PHYT'S, avec son propre board.

.DESCRIPTION
Écrit PROJETS/<Projet>/Related/<Feature>/ avec son .kanban-board.json et la
note Feature. Le parent reste vide : la note porte son propre board, et sur ce
board une carte sans parent est la carte feature qui reçoit les tâches. Une
carte n'appartient qu'au board marqué le plus proche d'elle — la Feature
n'apparaît donc plus sur le board du projet, elle n'y est pas comptée deux fois.

.EXAMPLE
.\New-Feature.ps1 -Projet Support-Mail-Assistant -Nom "Client Graph API" -Description "Wrapper src/graph.ts."
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory)][string]$Projet,
  [Parameter(Mandatory)][string]$Nom,
  [Parameter(Mandatory)][string]$Description,
  [string]$Statut = 'À faire',
  [string]$Priorite = 'Moyenne',
  [switch]$Commit
)

. (Join-Path (Join-Path (Split-Path $PSScriptRoot -Parent) '_phyts') '_phyts.ps1')

Assert-Valeur $Statut   $STATUTS   'Statut'
Assert-Valeur $Priorite $PRIORITES 'Priorité'
Assert-NomFichier $Nom

$vault   = Get-Vault
$racine  = Join-Path $vault "PROJETS\$Projet"
if (-not (Test-Path $racine)) { throw "Projet introuvable : $racine" }

# Le dossier d'une Feature déroge au nom exact : il porte le slug de sa
# branche Git (feat/<slug>), pas le titre complet — voir PROJETS/CLAUDE.MD.
# La note $Nom.md à l'intérieur garde elle le titre exact : c'est elle
# l'identifiant de la carte.
$slug    = Get-Slug $Nom
$dossier = Join-Path $racine "Features\$slug"
if (Test-Path $dossier) { throw "Existe déjà : $dossier" }

$fm = New-Frontmatter -Type 'Feature' -Statut $Statut -Priorite $Priorite -Epic $Projet

Write-Note (Join-Path $dossier "$Nom.md") "$fm`n`n# $Nom`n`n$Description`n"

$board = "{`n  ""name"": ""$Nom"",`n  ""description"": ""$Description""`n}"
Write-Note (Join-Path $dossier '.kanban-board.json') "$board`n"

Show-Cree @((Join-Path $dossier "$Nom.md"), (Join-Path $dossier '.kanban-board.json'))
Write-Host "Ajouter les tâches : ..\New-Tache\New-Tache.ps1 -Projet '$Projet' -Feature '$Nom' -Code A1 -Nom '<tâche>' -Description '<...>'"

if ($Commit) { Invoke-Commit $racine "feat($Projet): feature $Nom" }
