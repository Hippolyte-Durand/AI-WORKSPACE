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
  [string]$Epic = '',
  [switch]$Git,
  [switch]$Commit
)

. (Join-Path (Join-Path (Split-Path $PSScriptRoot -Parent) '_phyts') '_phyts.ps1')

Assert-Valeur $Statut   $STATUTS   'Statut'
Assert-Valeur $Priorite $PRIORITES 'Priorité'
Assert-NomFichier $Nom

$vault   = Get-Vault
$dossier = Join-Path $vault "PROJETS\$Nom"
if (Test-Path $dossier) { throw "Existe déjà : $dossier" }

$fm = New-Frontmatter -Type 'Projet' -Statut $Statut -Priorite $Priorite -Epic $Epic `
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

New-Item -ItemType Directory -Path (Join-Path $dossier 'Features') -Force | Out-Null

# Ce projet est un depot git independant : la remontee CLAUDE.md/AGENTS.md
# s'arrete a sa propre racine, elle ne voit jamais PROJETS/README.md du
# vault au-dessus. Trio README (source) + CLAUDE.md/AGENTS.md (pointeurs)
# necessaire ici, pas juste au niveau du vault.
$noteUrl = [uri]::EscapeDataString("$Nom.md") -replace '%2F', '/'
$readme = @"
---
tags:
  - L1
---

# $Nom

Dépôt du projet PHYT'S *$Nom* — dépôt git indépendant du vault ``PHYTS``
(voir ``PROJETS/README.md`` du vault pour le schéma frontmatter et les
règles générales ; hors du vault, ce fichier n'est pas accessible, d'où ce
README autonome).

Brief et plan complets : [``$Nom.md``]($noteUrl). Statut suivi par
[KANBAN-PHYTS](../../TOOLS/KANBAN-PHYTS/README.md) sur la ref ``main``.

## Features

<!-- INDEX:START -->
Aucune Feature pour l'instant.
<!-- INDEX:END -->
"@
Write-Note (Join-Path $dossier 'README.md') $readme

Write-Note (Join-Path $dossier 'CLAUDE.md') @'
Ce dossier a des règles. Lire [README.md](README.md) — c'est la source,
ce fichier n'existe que pour forcer Claude Code à le charger et router
correctement dans ce dossier ; ne jamais y recopier le contenu.
'@

Write-Note (Join-Path $dossier 'AGENTS.md') @'
Ce dossier a des règles. Lire [README.md](README.md) — c'est la source,
ce fichier n'existe que pour forcer les outils qui chargent `AGENTS.md`
(Kimi Code, Antigravity...) à le lire et router correctement dans ce
dossier ; ne jamais y recopier le contenu.
'@

Show-Cree @(
  (Join-Path $dossier "$Nom.md"), (Join-Path $dossier '.kanban-board.json'),
  (Join-Path $dossier 'Features'), (Join-Path $dossier 'README.md'),
  (Join-Path $dossier 'CLAUDE.md'), (Join-Path $dossier 'AGENTS.md')
)

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
