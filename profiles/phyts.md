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
1. **Une règle d'infra modifiée porte le n° du ticket qui l'a motivée.** La trace
   remonte du script au demandeur, sinon personne ne sait pourquoi c'est là.
2. **Un ticket résolu deux fois devient un runbook** dans `WIKI-KB/Procédures & RunBooks/`.
   La deuxième occurrence est le déclencheur, pas la première.
3. **Rien en prod sans validation Stéphane** — AD, réseau, M365, accès. Proposer, pas appliquer.
4. **`secrets/` ne sort jamais du poste.** Pas dans un ticket, pas dans un prompt,
   pas dans une note. Référencer l'emplacement, jamais la valeur.
5. **Écrire pour l'utilisateur final**, pas pour l'informaticien : `Reply.md` se lit
   par quelqu'un qui ne connaît ni le terme technique ni l'architecture.
