# Briques communes aux scripts d'échafaudage du vault PHYT'S.
# Chargé par les autres scripts, pas exécuté seul.

$ErrorActionPreference = 'Stop'

# Vocabulaire reconnu par KANBAN-PHYTS. Une valeur hors liste n'efface pas la
# carte, elle atterrit en Backlog — donc invisible là où on l'attend.
$script:STATUTS  = @('Backlog', 'À faire', 'En Cours', 'Bloqué', 'Revue', 'Terminé')
$script:PRIORITES = @('Critique', 'Haute', 'Moyenne', 'Basse')

# Nom de dossier dérivé d'un titre : minuscules, tirets, sans accent. Sert au
# dossier d'une Feature (qui reprend le slug de sa branche Git), jamais au nom
# de fichier de la note — celui-là reste le titre exact, c'est l'identifiant
# de la carte (PROJETS/README.md).
function Get-Slug($texte) {
  $sansAccent = $texte.Normalize([Text.NormalizationForm]::FormD) `
    -replace '\p{Mn}', ''
  $slug = $sansAccent.ToLowerInvariant() -replace '[^a-z0-9]+', '-'
  return $slug.Trim('-')
}

function Get-Vault {
  if ($env:PHYTS_VAULT) { $r = $env:PHYTS_VAULT }
  else { $r = Join-Path $HOME 'Documents\PHYTS' }
  if (-not (Test-Path $r)) { throw "Vault introuvable : $r (définir PHYTS_VAULT pour le déplacer)" }
  return (Resolve-Path $r).Path
}

function Assert-Valeur($valeur, $admises, $nom) {
  if ($admises -notcontains $valeur) {
    throw "$nom « $valeur » hors vocabulaire. Admis : $($admises -join ', ')"
  }
}

# Windows refuse ces caractères dans un nom de fichier, et le nom de fichier est
# l'identifiant de la carte : mieux vaut refuser tôt que produire un board muet.
function Assert-NomFichier($nom) {
  if ($nom -match '[\\/:*?"<>|]') {
    throw "Nom « $nom » : les caractères \ / : * ? "" < > | sont interdits dans un nom de fichier."
  }
}

# UTF-8 sans BOM, fins de ligne LF : ce que git et le serveur du board lisent
# sans surprise. Set-Content de PowerShell 5.1 écrirait un BOM.
function Write-Note($chemin, $contenu) {
  if (Test-Path $chemin) { throw "Existe déjà : $chemin" }
  $dossier = Split-Path $chemin -Parent
  if (-not (Test-Path $dossier)) { New-Item -ItemType Directory -Path $dossier -Force | Out-Null }
  $texte = ($contenu -replace "`r`n", "`n")
  [IO.File]::WriteAllText($chemin, $texte, (New-Object Text.UTF8Encoding $false))
}

function New-Frontmatter {
  param($Type, $Statut, $Priorite, $Epic = '', $Parent = '', $DateDebut = '', $Extra = @{}, $AVerifier = $null)

  $lignes = @(
    '---'
    "type: $Type"
    "statut: $Statut"
    "priorite: $Priorite"
  )
  if ($Epic) { $lignes += "epic: $Epic" } else { $lignes += 'epic:' }
  foreach ($k in $Extra.Keys) { $lignes += "$k`: $($Extra[$k])" }
  if ($DateDebut) { $lignes += "date_debut: $DateDebut" } else { $lignes += 'date_debut:' }
  $lignes += 'date_fin:'
  $lignes += 'date_echeance:'
  # Nom nu, jamais de [[wikilink]] : le board compare `parent` à l'identifiant
  # d'une carte par égalité stricte, et un lien entre crochets ne matche rien.
  if ($Parent) { $lignes += "parent: ""$Parent""" } else { $lignes += 'parent:' }
  $lignes += 'documentation:'
  $lignes += 'runbook:'
  # Champ Ticket uniquement (TICKETS/README.md) — absent du schéma PROJETS,
  # donc rendu seulement si explicitement fourni par l'appelant.
  if ($null -ne $AVerifier) {
    $items = @($AVerifier | ForEach-Object { '"' + ($_ -replace '"', '\"') + '"' }) -join ', '
    $lignes += "a_verifier: [$items]"
  }
  $lignes += '---'
  return ($lignes -join "`n")
}

# Corps d'un gabarit, frontmatter et titre retirés : seules les sections servent.
function Get-CorpsGabarit($chemin) {
  if (-not (Test-Path $chemin)) { return $null }
  $brut = [IO.File]::ReadAllText($chemin) -replace "`r`n", "`n"
  $brut = $brut -replace '(?s)^---\n.*?\n---\n', ''
  $brut = $brut -replace '(?m)^#\s+.*\n', ''
  $t = $brut.Trim()
  if ($t) { return $t } else { return $null }
}

function Invoke-Commit($depot, $message) {
  Push-Location $depot
  try {
    if (-not (Test-Path (Join-Path $depot '.git'))) {
      Write-Host "Pas un dépôt git : $depot — commit ignoré." -ForegroundColor Yellow
      return
    }
    git add -A
    git commit -q -m $message
    Write-Host "Commité dans $(Split-Path $depot -Leaf) : $message"
    Write-Host 'Le board lit la ref git : pousser pour que les autres le voient.' -ForegroundColor Yellow
  } finally { Pop-Location }
}

function Show-Cree($chemins) {
  Write-Host 'Créé :' -ForegroundColor Green
  foreach ($c in $chemins) { Write-Host "  $c" }
}
