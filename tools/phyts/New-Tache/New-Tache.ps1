<#
.SYNOPSIS
Crée une Tâche dans une Feature d'un projet du vault PHYT'S.

.DESCRIPTION
Écrit PROJETS/<Projet>/Related/<Feature>/<Code> - <Nom>.md. Le champ parent
porte le nom nu de la Feature, jamais un [[wikilink]] : le board compare parent
à l'identifiant d'une carte — le nom de fichier sans extension — par égalité
stricte, et une tâche qui ne matche rien n'apparaît sur aucune colonne.

.EXAMPLE
.\New-Tache.ps1 -Projet Support-Mail-Assistant -Feature "Client Graph API" -Code B1 -Nom listSupportMessages -Description "Lecture des mails de l'inbox support."
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory)][string]$Projet,
  [Parameter(Mandatory)][string]$Feature,
  [Parameter(Mandatory)][string]$Code,
  [Parameter(Mandatory)][string]$Nom,
  [Parameter(Mandatory)][string]$Description,
  [string]$Statut = 'À faire',
  [string]$Priorite = 'Moyenne',
  [switch]$Commit
)

. (Join-Path (Join-Path (Split-Path $PSScriptRoot -Parent) '_phyts') '_phyts.ps1')

Assert-Valeur $Statut   $STATUTS   'Statut'
Assert-Valeur $Priorite $PRIORITES 'Priorité'

$vault   = Get-Vault
$racine  = Join-Path $vault "PROJETS\$Projet"
$slug    = Get-Slug $Feature
$dossier = Join-Path $racine "Features\$slug\Taches"
if (-not (Test-Path $dossier)) { throw "Feature introuvable : $dossier (dossier attendu : Features\$slug)" }

$fichier = "$Code - $Nom"
Assert-NomFichier $fichier

$fm = New-Frontmatter -Type 'Tache' -Statut $Statut -Priorite $Priorite -Parent $Feature

Write-Note (Join-Path $dossier "$fichier.md") "$fm`n`n# $fichier`n`n$Description`n"

Show-Cree @((Join-Path $dossier "$fichier.md"))

if ($Commit) { Invoke-Commit $racine "feat($Projet): $Code $Nom" }
