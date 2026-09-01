---
name: runbook
description: Transforme une résolution de ticket qui va se reproduire en procédure rejouable dans WIKI-KB. Déclencheurs "fais-en un runbook", "documente cette procédure", ou la deuxième occurrence d'un même incident.
---

# Runbook PHYT'S

Un incident résolu deux fois est un incident qui reviendra. Ce skill transforme
la résolution en procédure qu'un tiers — ou soi-même dans six mois — rejoue sans
redécouvrir le raisonnement.

Source : $ARGUMENTS (n° de ticket, ou description de la manip à figer)

## Le déclencheur, c'est la deuxième fois
Pas la première. Écrire un runbook pour un incident unique produit de la doc
morte que personne ne relit. La deuxième occurrence prouve la récurrence — c'est
elle qui justifie le coût d'écriture.

Exception : une manip **rare mais critique** (restauration, bascule, sortie de
collaborateur) se documente dès la première, parce que le jour où elle sert,
personne n'a le temps de réfléchir.

## Emplacement
`~/Documents/PHYTS/WIKI-KB/Procédures & RunBooks/<Verbe à l'infinitif>.md`

Titre = l'action, pas le symptôme : `Réinitialiser un mot de passe AD.md`, pas
`Problème de connexion.md`. On cherche un runbook par ce qu'on veut faire.

Les trois foyers de `WIKI-KB/` ne se mélangent pas :
- `Procédures & RunBooks/` — **on fait quoi, dans quel ordre** (ici)
- `Documentations/` — comment un système est monté, son état
- `Concepts/` — pourquoi une notion marche comme ça

## Structure

```markdown
---
type: runbook
tickets: ["3843", "3901"]     # les occurrences qui l'ont motivé
systemes: [AD, M365]
maj_le:
---

<!-- Pas de `statut` ici, volontairement : WIKI-KB n'est pas un board. Un champ
     `statut` ferait apparaître le runbook comme une carte parmi les tickets. -->

# <Verbe> <objet>

## Quand l'utiliser
Le symptôme exact, tel qu'il arrive par mail. C'est la clé d'entrée : si ça ne
ressemble pas à ce que le demandeur écrit, le runbook ne sera pas retrouvé.

## Prérequis
Droits nécessaires, accès, ce qu'il faut avoir sous la main. Un prérequis
manquant découvert à l'étape 4 fait tout recommencer.

## Étapes
1. Une action par étape, à l'impératif, avec la commande exacte.
2. Ce qu'on doit voir quand ça marche — sinon impossible de savoir si on
   continue ou si on s'est trompé.

## Vérification
Comment prouver que c'est réglé, côté utilisateur — pas côté serveur.

## Si ça ne marche pas
Les deux ou trois échecs déjà rencontrés, et leur sortie. À partir d'ici,
escalade Stéphane.
```

## Règles

- **Commandes exactes, jamais paraphrasées.** « Ouvrir la console AD et chercher
  l'utilisateur » se retape de dix façons ; `Get-ADUser -Identity <sam> -Properties *`
  se copie. Les valeurs variables en `<chevrons>`.
- **Le pourquoi va dans `Concepts/`, pas ici.** Un runbook qui explique se lit
  mal en situation d'urgence. Un lien suffit.
- **Rien qui vienne de `INFRA/secrets/`.** Le runbook dit où chercher
  l'identifiant, jamais sa valeur. Un runbook, ça se partage.
- **Lier les tickets sources** dans le frontmatter, et lier le runbook depuis
  leur section `Résolution`. Le lien se pose dans les deux sens ou il ne sert
  qu'à moitié.
- **Toute action non réversible porte son avertissement AVANT l'étape**, pas
  après — avec ce qu'il faut avoir sauvegardé pour pouvoir revenir en arrière.
- **Un runbook rejoué qui a dévié se corrige le jour même.** Une procédure fausse
  coûte plus cher que pas de procédure : elle est suivie avec confiance.

## Si la manip est scriptable
Une procédure entièrement mécanique n'a pas vocation à rester manuelle : la
porter dans `INFRA/powershell/` ou `INFRA/ansible/`, et réduire le runbook à
« lancer ce script, vérifier ceci ». Le runbook garde la vérification et les
cas d'échec — le script, lui, ne les documente pas.
