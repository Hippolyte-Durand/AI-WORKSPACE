<#
.SYNOPSIS
Régénère l'index (table markdown) entre <!-- INDEX:START --> et
<!-- INDEX:END --> dans TICKETS/README.md ou PROJETS/README.md, depuis le
frontmatter réel des notes — jamais tenu à la main (règle 7 : dérive
doc/réel sur un contenu qui bouge).

.EXAMPLE
.\Update-Index.ps1 -Cible Tickets

.EXAMPLE
.\Update-Index.ps1 -Cible Projets
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory)][ValidateSet('Tickets', 'Projets')][string]$Cible
)

. (Join-Path (Join-Path (Split-Path $PSScriptRoot -Parent) '_phyts') '_phyts.ps1')

function Get-Frontmatter($chemin) {
  $texte = ([IO.File]::ReadAllText($chemin)) -replace "`r`n", "`n"
  if ($texte -notmatch '(?s)^---\n(.*?)\n---') { return @{} }
  $fm = @{}
  foreach ($ligne in ($Matches[1] -split "`n")) {
    if ($ligne -match '^([a-z_]+):\s*(.*)$') { $fm[$Matches[1]] = $Matches[2].Trim() }
  }
  return $fm
}

# Cherche dans $dossier (non récursif) le .md dont le frontmatter porte
# type: $type — ne suppose pas que le nom de fichier matche le dossier
# (des projets existants ont un dossier en tirets, une note en espaces).
function Find-Note($dossier, $type) {
  Get-ChildItem $dossier -File -Filter '*.md' | ForEach-Object {
    if ((Get-Frontmatter $_.FullName)['type'] -eq $type) { return $_ }
  } | Select-Object -First 1
}

# Premier paragraphe du corps (le pitch), une ligne, sans markdown ni
# frontmatter ni titres (#, ##...) — tronqué pour rester lisible en table.
function Get-Objet($chemin) {
  $texte = ([IO.File]::ReadAllText($chemin)) -replace "`r`n", "`n"
  $sansFm = $texte -replace '(?s)^---\n.*?\n---\n', ''
  $sansTitres = $sansFm -replace '(?m)^#{1,6}\s+.*\n', ''
  $premier = ($sansTitres.Trim() -split "`n`n")[0]
  $ligne = ($premier -replace '\s+', ' ').Trim()
  if ($ligne.Length -gt 140) { $ligne = $ligne.Substring(0, 137) + '...' }
  return $ligne
}

# Ecrit $table entre les marqueurs INDEX de $readme. Erreur si les
# marqueurs n'existent pas — mieux vaut echouer que deviner ou l'inserer.
function Set-IndexSection($readme, $table) {
  $contenu = ([IO.File]::ReadAllText($readme)) -replace "`r`n", "`n"
  if ($contenu -notmatch '(?s)<!-- INDEX:START -->\n.*?<!-- INDEX:END -->') {
    throw "Marqueurs <!-- INDEX:START/END --> introuvables dans $readme"
  }
  $nouveau = $contenu -replace '(?s)<!-- INDEX:START -->\n.*?<!-- INDEX:END -->', "<!-- INDEX:START -->`n$table`n<!-- INDEX:END -->"
  [IO.File]::WriteAllText($readme, $nouveau, (New-Object Text.UTF8Encoding $false))
  Write-Host "Index régénéré : $readme" -ForegroundColor Green
}

$vault = Get-Vault

if ($Cible -eq 'Tickets') {
  $racine  = Join-Path $vault 'TICKETS'
  $readme  = Join-Path $racine 'README.md'
  $lignes = @('| Ticket | Statut | Priorité | Catégorie | Objet |', '|---|---|---|---|---|')
  Get-ChildItem $racine -Directory | Sort-Object Name | ForEach-Object {
    $note = Find-Note $_.FullName 'Ticket'
    if (-not $note) { return }
    $fm = Get-Frontmatter $note.FullName
    $objet = Get-Objet $note.FullName
    $lignes += "| ``$($_.Name)`` | $($fm['statut']) | $($fm['priorite']) | $($fm['categorie']) | $objet |"
  }
  Set-IndexSection $readme ($lignes -join "`n")
  return
}
else {
  $racine = Join-Path $vault 'PROJETS'
  $readme = Join-Path $racine 'README.md'
  $lignesTop = @('| Projet | Statut | Priorité | Objet | Découpage | Dépôt |', '|---|---|---|---|---|---|')
  $sousTables = @()

  Get-ChildItem $racine -Directory | Sort-Object Name | ForEach-Object {
    $projetNom = $_.Name
    $note = Find-Note $_.FullName 'Projet'
    if (-not $note) { return }
    $fm = Get-Frontmatter $note.FullName
    $objet = Get-Objet $note.FullName

    $features = @()
    $featuresDir = Join-Path $_.FullName 'Features'
    if (Test-Path $featuresDir) { $features = Get-ChildItem $featuresDir -Directory }

    $nbTaches = 0
    foreach ($f in $features) {
      $tDir = Join-Path $f.FullName 'Taches'
      if (Test-Path $tDir) { $nbTaches += (Get-ChildItem $tDir -Filter '*.md').Count }
    }
    $decoupage = if ($features.Count -eq 0) { 'Non découpé' } else { "$($features.Count) boards Feature / $nbTaches Tâches" }
    $depot = "PHYTS-$projetNom"

    $lignesTop += "| ``$projetNom`` | $($fm['statut']) | $($fm['priorite']) | $objet | $decoupage | ``$depot`` |"

    $entete = @('| Code | Feature | Tâches | Statut | Objet |', '|---|---|---|---|---|')
    $tableFeatures = 'Aucune Feature pour l''instant.'
    if ($features.Count -gt 0) {
      $rangees = foreach ($f in $features) {
        $fNote = Get-ChildItem $f.FullName -File -Filter '*.md' | Select-Object -First 1
        if (-not $fNote) { continue }
        $fFm = Get-Frontmatter $fNote.FullName
        $fObjet = Get-Objet $fNote.FullName
        $tDir = Join-Path $f.FullName 'Taches'
        $nbT = 0; $code = '?'
        if (Test-Path $tDir) {
          $taches = Get-ChildItem $tDir -Filter '*.md' | Sort-Object Name
          $nbT = $taches.Count
          if ($nbT -gt 0 -and $taches[0].BaseName -match '^([A-Za-z]+)\d') { $code = $Matches[1] }
        }
        [PSCustomObject]@{ Code = $code; Feature = $fNote.BaseName; Taches = $nbT; Statut = $fFm['statut']; Objet = $fObjet }
      }
      $lignesFeatures = foreach ($r in ($rangees | Sort-Object Code)) {
        "| $($r.Code) | $($r.Feature) | $($r.Taches) | $($r.Statut) | $($r.Objet) |"
      }
      $tableFeatures = ($entete + $lignesFeatures) -join "`n"
      $sousTables += (@("### $projetNom — boards Feature", '') + $entete + $lignesFeatures) -join "`n"
    }

    # Index local, auto-contenu — utile meme si ce depot est clone seul,
    # hors du vault (voir Set-IndexSection dans son propre README.md).
    $readmeLocal = Join-Path $_.FullName 'README.md'
    if (Test-Path $readmeLocal) { Set-IndexSection $readmeLocal $tableFeatures }
  }

  $table = ($lignesTop -join "`n")
  if ($sousTables.Count -gt 0) { $table += "`n`n" + ($sousTables -join "`n`n") }
  Set-IndexSection $readme $table
}
