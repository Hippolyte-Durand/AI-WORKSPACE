# Profil PHYT'S — contexte poste

## Qui, où
Hippolyte Durand, **Chargé de Support Informatique, Automatisation & Projet SI**
chez PHYT'S (PME cosmétique bio, Lot). Alternance, master architecture SI.
Responsable SI : **Stéphane Cristol** — c'est lui qui arbitre tout ce qui touche
à la prod, au réseau et aux accès.

Poste = quatre casquettes, dans cet ordre de fréquence :

| Axe | Ce que ça veut dire au quotidien |
|---|---|
| **Support utilisateur** | demandes entrantes (mail, appel, passage), incidents postes/impression/M365/AD |
| **Gestion de projet** | projets SI suivis en notes `Projet` → `Feature` → `Tâche` |
| **Dev backend** | automatisations PowerShell/Ansible/Terraform, scripts d'intégration, API internes |
| **IA** | agents et skills qui absorbent le répétitif des trois axes au-dessus |

## Le vault PHYT'S
Racine : `~/Documents/PHYTS`. Quatre foyers, chacun son git propre :

- `TICKETS/` — un dossier par demande, nommé `<Titre> (<n°>)`. Contient
  `Incident.md` (Constat / Impact / Diagnostic / Résolution), `Reply.md`
  (texte à renvoyer au demandeur), `doc/` (pièces jointes, kebab-case, datées).
  Board Kanban « Helpdesk » : seuls les `.md` portant un `status` deviennent des cartes.
- `PROJETS/` — un dossier par projet, notes `Projet`/`Feature`/`Tâche`
  (frontmatter `type`/`statut`/`priorite`/`parent`). Board Kanban propre.
- `WIKI-KB/` — `Concepts/`, `Documentations/`, `Procédures & RunBooks/`.
  Capitalisation : une résolution de ticket qui se reproduira devient un runbook ici.
- `INFRA/` — code d'infra réel : `ad/`, `ansible/`, `m365/`, `network/`,
  `powershell/`, `terraform/`, `audit/`, `secrets/` (jamais commité en clair).

## Règles de travail
Voir `PHYTS/CLAUDE.md` (racine du vault) — seul texte source, chargé
automatiquement par le harness pour tout ce qui vit sous `PHYTS/`, y compris
les sous-dépôts (`PROJETS/`, `TICKETS/`, …). Pas de copie ici.
