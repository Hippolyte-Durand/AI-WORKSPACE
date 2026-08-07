---
name: new-client
description: Crée un client (entité + memory + runbook (infra→Infra, contacts→Contacts), lazy)
disable-model-invocation: true
---

Crée un client nommé : $ARGUMENTS

Conventions : **pas de préfixe acronyme** sur les fichiers memory (`brief.md`, pas `AC-brief.md`). **Cockpit nommé par le slug** (`<slug>.md`, pas `Home-`). Infra = **modèle machine seule, NIC embarquées** (`nic1_*`), pas de dossiers `nics/`/`reseaux/` séparés. Bases = `DB/` (jamais `BASES/`). Liens frontmatter = **chaîne guillemetée** (`clients: ["[[<slug>]]"]`).

## Inputs
| Fichier | Couche | Sections | Pourquoi |
|---|---|---|---|
| `_TEMPLATES/{client,memory-*,contact,infra,machine}.md` | L3 | tout | structure client + memory + contacts/infra |
| `DOCTRINE.md` | L3 | `#foyer-unique`, `#memory`, `#view-mocs` | foyers plats (Infra/Contacts) + memory 5 fichiers + règles UX views |
| `$ARGUMENTS` + réponses champs | L4 | — | nom/trigramme/contacts |

1. **Slug** = kebab-case (`awesome-corp`). **Trigramme** = code court MAJ (`AC`, `SOL`) → sert de préfixe hostnames. **Date** = today.

2. Arbo — **lazy, zéro scaffold vide**. Day 1 = cockpit + `memory/`. Le reste naît au premier fichier (mkdir juste-à-temps).
   ```
   DATA/3-Resources/Clients/<slug>/
   ├── <slug>.md               ← type: entreprise (cockpit du client, inline ```base``` sections)
   ├── <slug>-constraints.md   ← doc spécifique client (type: topic, FK clients:) — à la RACINE, pas de doc/
   ├── memory/                 ← brief.md decisions.md apprentissages.md blocages.md sessions.md
   └── runbook/                ← procédures ops spécifiques-client (type: procedure, FK clients:) — créé à la 1re
   ```
   > **Pas de `doc/`, `views/`, `infra/` ni `contacts/` client.** Machines/infra → **`3-Resources/Infra/`** ; contacts → **`3-Resources/Contacts/`** ; savoir réutilisable → **`3-Resources/KB/`** — tous plats, FK `clients: ["[[<slug>]]"]` / `related`. Seul le spécifique-client (contraintes, procédures ops) vit chez le client. Tout surfacé par les vues via `clients:`.

3. **`<slug>.md`** depuis `_TEMPLATES/client.md` :
   - `type: entreprise`, `acronyme: <TRI>`, `statut: actif`, `contrat:`, `contacts: ["[[<contact princ>]]"]`, `créé: <date>`, `maj: <date>`
   - Sections inline ```base``` pour Projets, Contacts, Machines (avec `file.hasLink(this.file)` — jamais `client == this.asLink()` qui ne fonctionne pas), pas de liens vers sous-pages.

4. **Memory** depuis `_TEMPLATES/memory-{brief,decisions,apprentissages,blocages,sessions}.md` :
   - Frontmatter : `clients: ["[[<slug>]]"]` (array), `maj: <date>`. Supprimer les champs `projets:` et `features:` du brief (non pertinents day 1). Ajouter `projets: ["[[]]"]` vide — à compléter au premier projet créé pour ce client (routing brief client → briefs projets).

5. **Contacts** → `3-Resources/Contacts/` (plat, PAS chez le client) : 1 note `Contacts/<prenom>.md` depuis `_TEMPLATES/contact.md` → `type: contact`, `clients: ["[[<slug>]]"]`, `poste/email/phone` (jamais `role`/`tel` — cf. `SCHEMA.md#contact`).

6. **Infra** → `3-Resources/Infra/` (plat, PAS chez le client) : `Infra/<slug>-infra.md` depuis `_TEMPLATES/infra.md` (+ `clients: ["[[<slug>]]"]`) ; `Infra/<hostname>.md` depuis `_TEMPLATES/machine.md`, chaque machine `clients: ["[[<slug>]]"]` (FK **array**, jamais le singulier `client:` — cf. `SCHEMA.md#machine`).

7. **Procédures ops** (à la demande) : `runbook/<slug>-<nom>.md`, `type: procedure`, FK `clients: ["[[<slug>]]"]`, champs ops optionnels (`impact`, `duration-est`). Pas de type `runbook`, pas d'index. Procédure générique → KB à la place.

8. **Docs client** : `<slug>-constraints.md` à la **racine** du client (nom préfixé slug = unicité `[[…]]`, pas de collision entre clients ; `type: topic`, FK `clients: ["[[<slug>]]"]`). Aucun dossier `doc/`. Tout savoir réutilisable va en `3-Resources/KB/` (rattaché `related: - "[[<slug>]]"`).

9. **Bases** (automatique) : `DB/Clients.base` (type entreprise) · `Contacts.base` (type contact) · `Machines.base` + `Projets.base` colonne `clients`. Rien à créer. `HOME.md` liste clients automatiquement via `![[Home-Clients.base]]`.

10. `python3 _APP/sync-memory-downlinks.py` → remplit les down-links entreprise↔memory (briefs/decisions/sessions/blocages/apprentissages, pas d'evals).
11. Vérifie `python3 _APP/check-vault-integrity.py`. Confirme slug, trigramme, date.
