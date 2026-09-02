---
name: support-ticket
description: Transforme une demande utilisateur entrante (mail, appel, passage) en dossier ticket PHYT'S — Incident.md instruit et Reply.md prêt à envoyer. Déclencheurs "nouveau ticket", "traite cette demande", "j'ai un incident", ou un mail collé tel quel.
---

# Support ticket PHYT'S

Une demande arrive brute — mail transféré, note d'appel, quelqu'un qui passe au
bureau. Ce skill la range en dossier ticket exploitable, et rédige la réponse au
demandeur dans SA langue à lui, pas en jargon.

Source : $ARGUMENTS

## Portée
Instruction et traçage du ticket. **Pas d'application en prod** : AD, réseau,
M365, accès et GPO se proposent, ne s'appliquent pas — Stéphane Cristol arbitre.
Un correctif local sur un poste isolé reste à la main du support.

## Emplacement
`~/Documents/PHYTS/TICKETS/<Titre court> (<n° ticket>)/`

Le n° vient de **GLPI**. **Pas de numéro fourni → demander, ne pas inventer** :
un ticket sans n° ne se recroise avec rien. Les consignes de saisie GLPI (intitulé
court cherchable, recopie du mail, tâche pour ce qui a été fait, solution pour
clore) sont dans `WIKI-KB/Documentations/GLPI - Convention de saisie.md` — GLPI
reste le registre officiel, le dossier ici en est l'instruction technique.

Ticket de type "préparation / configuration de poste" : voir aussi
`WIKI-KB/Documentations/GLPI - Clôture préparation de poste.md` (format de
sortie attendu) et le skill `cloture-preparation-poste` pour la clôture.

```
<Titre court> (<n°>)/
├── Incident.md    ← l'instruction (le .md qui porte statut = carte du board Helpdesk)
├── Reply.md       ← le texte à renvoyer au demandeur
└── doc/           ← pièces : exports, captures, journaux (kebab-case, datés)
```

## Process

1. **Extraire** de la source : qui demande, quel poste/service, symptôme exact,
   depuis quand, ce qui a changé récemment, urgence réelle (≠ urgence ressentie).
2. **Ce qui manque se demande**, une question à la fois. Ne jamais combler un
   trou par une hypothèse présentée comme un fait — un diagnostic bâti sur du
   supposé fait perdre le déplacement suivant.
3. **Chercher l'antériorité avant de diagnostiquer** : `WIKI-KB/Procédures & RunBooks/`
   puis les `TICKETS/` clos. Un incident déjà résolu se rejoue, il ne se
   re-diagnostique pas. Toute procédure trouvée qui s'applique **s'attache
   tout de suite** au champ `runbook:` de l'`Incident.md` (étape suivante) —
   pas seulement citée dans `## Résolution`. Plusieurs procédures qui
   s'appliquent : lister leurs chemins, séparés par une virgule.
4. **Écrire `Incident.md`** — schéma identique à celui des notes `PROJETS/`
   (voir `PROJETS/CLAUDE.MD`), avec `type: Ticket` et `epic: Helpdesk`
   fixes :

   ```markdown
   ---
   type: Ticket
   statut: À faire        # Backlog | À faire | En Cours | Bloqué | Revue | Terminé
   priorite: Moyenne      # Critique | Haute | Moyenne | Basse
   epic: Helpdesk
   date_debut:
   date_fin:
   date_echeance:
   parent:
   documentation:
   runbook:                # chemin(s) trouvés à l'étape 3, sinon vide
   ---

   # Incident

   ## Constat
   Ce qui est observé, par qui, depuis quand. Mots du demandeur si utiles, cités.

   ## Impact
   Postes, services et utilisateurs touchés. Combien de personnes bloquées, et
   sur quoi — c'est ça qui fixe la priorité, pas le ton du mail.

   ## Diagnostic
   Ce qui a été vérifié, et ce que ça a donné. Les pistes écartées comptent
   autant que la bonne : sans elles, le prochain refait les mêmes tests.

   ## Résolution
   Actions appliquées. Une règle d'infra modifiée porte le n° de ce ticket.
   ```

5. **Écrire `Reply.md`** — voir ci-dessous.
6. **Boucler** : `statut: Terminé`, résolution renseignée, puis **commit et push
   sur `main`**. Si le symptôme est le **deuxième** du même type, invoquer
   `runbook` pour capitaliser.

## Ce qui fait qu'une carte apparaît sur le board

Le board Helpdesk vient de **KANBAN-PHYTS**, qui lit une **ref git** (`main` par
défaut), jamais l'arbre de travail. Trois conditions, toutes nécessaires :

1. Le `.md` porte un frontmatter avec `statut` (ou `status`). **Sans lui, le
   fichier n'est pas une carte** — il n'est ni en erreur ni signalé, il est absent.
2. La valeur tombe dans le vocabulaire ci-dessus. Une valeur inconnue n'efface pas
   la carte : elle atterrit en **Backlog**, ce qui se voit mais se lit mal. `Résolu`,
   `À traiter`, `En attente` ne sont **pas** reconnus — respectivement `Terminé`,
   `À faire`, `Bloqué`.
3. C'est **commité et poussé**. Un ticket écrit et non poussé n'existe pour personne.

Le dossier `Template_Ticket` est ignoré par le board : y écrire un vrai ticket
revient à le rendre invisible.

## Reply.md — la partie qui se lit vraiment

Le demandeur n'est ni informaticien ni intéressé par l'architecture. Quatre lignes :

1. Ce qui se passait, dans ses mots à lui.
2. Ce qui a été fait — sans nom de service, de GPO ni de commande.
3. Ce qu'il doit faire, lui, maintenant (souvent : rien, ou redémarrer).
4. Quoi faire si ça revient.

Pas de « votre problème est lié à une règle de redirection de dossier appliquée
par GPO ». Plutôt : « vos documents pointaient vers l'ancien serveur, c'est
corrigé — rouvrez Word, dites-moi si un fichier manque encore ».

## Traçabilité
Une règle d'infra, un script `INFRA/powershell/` ou un playbook modifié pour ce
ticket **porte son n° en commentaire**. C'est le seul fil qui relie une ligne de
code au problème humain qui l'a causée, six mois plus tard.

## Sécurité
`INFRA/secrets/` ne sort jamais : ni dans le ticket, ni dans `doc/`, ni dans un
prompt. Un identifiant se référence par son emplacement, jamais par sa valeur.
Un export utilisateur (AD, M365) collé dans `doc/` est de la donnée personnelle —
il n'y reste que le temps du ticket.

## Erreurs courantes
- Créer le dossier sans n° de ticket — plus recroisable avec le helpdesk.
- Remplir `Diagnostic` avec la cause supposée avant d'avoir vérifié quoi que ce soit.
- Une réponse au demandeur qui explique la cause technique au lieu de dire ce qu'il doit faire.
- Résoudre pour la deuxième fois sans écrire le runbook — la troisième fois arrivera.
- Recopier une valeur de `secrets/` dans une pièce jointe.
