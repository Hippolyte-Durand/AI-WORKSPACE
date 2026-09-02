<#
.SYNOPSIS
Liste les tickets PHYT'S clôturés (statut: Terminé) qui portent encore un
`a_verifier` non vide — la dérive statut/complétude détectable par script,
sans dépendre d'une relecture manuelle (voir TICKETS/README.md).

.EXAMPLE
.\Test-Tickets.ps1
#>
[CmdletBinding()]
param()

. (Join-Path (Join-Path (Split-Path $PSScriptRoot -Parent) '_phyts') '_phyts.ps1')

$vault   = Get-Vault
$tickets = Join-Path $vault 'TICKETS'

$trouves = 0
Get-ChildItem $tickets -Recurse -Filter '*.md' | ForEach-Object {
  $texte = [IO.File]::ReadAllText($_.FullName) -replace "`r`n", "`n"
  if ($texte -notmatch '(?s)^---\n(.*?)\n---') { return }
  $fm = $Matches[1]

  # Seule la carte porte `statut` — un README/Reply de pièce n'en a pas.
  if ($fm -notmatch '(?m)^statut:\s*Terminé\s*$') { return }

  if ($fm -match '(?m)^a_verifier:\s*\[(.*?)\]\s*$') {
    $contenu = $Matches[1].Trim()
    if ($contenu) {
      $trouves++
      Write-Host "$($_.Name)" -ForegroundColor Yellow
      Write-Host "  a_verifier: [$contenu]`n"
    }
  } else {
    # Pas de champ a_verifier du tout : schéma pas à jour sur ce ticket,
    # pas forcément un trou réel — à signaler différemment d'un vrai gap.
    $trouves++
    Write-Host "$($_.Name)" -ForegroundColor DarkYellow
    Write-Host "  champ a_verifier absent (schéma TICKETS/README.md pas appliqué)`n"
  }
}

if ($trouves -eq 0) {
  Write-Host 'Rien à signaler : tous les tickets Terminé ont a_verifier: [].' -ForegroundColor Green
} else {
  Write-Host "$trouves ticket(s) Terminé avec un trou déclaré ou un schéma pas à jour." -ForegroundColor Yellow
}
