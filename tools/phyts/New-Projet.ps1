<#
.SYNOPSIS
Crée un projet du vault PHYT'S : dossier, marqueur de board et note Projet.

.DESCRIPTION
Écrit PROJETS/<Nom>/ avec son .kanban-board.json et la note Projet portant le
plan. La note reste sans parent : une carte sans parent est une feature aux
yeux du board, une carte avec parent est une tâche.

.EXAMPLE
.\New-Projet.ps1 -Nom "Audit Sauvegardes" -Description "Vérifier la couverture des sauvegardes serveurs."

.EXAMPLE
.\New-Projet.ps1 -Nom "Audit Sauvegardes" -Description "..." -Priorite Haute -Git
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory)][string]$Nom,
  [Parameter(Mandatory)][string]$Description,
  [string]$Statut = 'À faire',
  [string]$Priorite = 'Moyenne',
  [switch]$Git,
  [switch]$Commit
)

. (Join-Path $PSScriptRoot '_phyts.ps1')

Assert-Valeur $Statut   $STATUTS   'Statut'
Assert-Valeur $Priorite $PRIORITES 'Priorité'
Assert-NomFichier $Nom

$vault   = Get-Vault
$dossier = Join-Path $vault "PROJETS\$Nom"
if (Test-Path $dossier) { throw "Existe déjà : $dossier" }

$fm = New-Frontmatter -Type 'Projet' -Statut $Statut -Priorite $Priorite `
                      -DateDebut (Get-Date -Format 'yyyy-MM-dd')

$corps = @"
$Description

## Contexte
Pourquoi ce projet existe maintenant.

## Objectifs
-

## Non-objectifs
-

## Approche
Architecture et approche retenues.

## Découpage Features → Tâches
- **<Feature>** — <raison d'être en une ligne>
  - A1 <tâche>
"@

Write-Note (Join-Path $dossier "$Nom.md") "$fm`n`n# $Nom`n`n$corps`n"

$board = "{`n  ""name"": ""$Nom"",`n  ""description"": ""$Description""`n}"
Write-Note (Join-Path $dossier '.kanban-board.json') "$board`n"

New-Item -ItemType Directory -Path (Join-Path $dossier 'Related') -Force | Out-Null

Show-Cree @((Join-Path $dossier "$Nom.md"), (Join-Path $dossier '.kanban-board.json'), (Join-Path $dossier 'Related'))

# Le board ne lit qu'une ref git : hors dépôt, un projet n'apparaît nulle part.
if ($Git) {
  Push-Location $dossier
  try {
    git init -q -b main
    "node_modules/`n*.log`n.env`n" | Set-Content -Path '.gitignore' -NoNewline -Encoding utf8
    Write-Host "Dépôt git initialisé. Remote attendu : DURAND-Hippolyte-PHYTS/PHYTS-$($Nom -replace ' ', '-')"
  } finally { Pop-Location }
}

if ($Commit) { Invoke-Commit $dossier "chore: initialiser le projet $Nom" }
