# Anti-patterns — skills vault

## Table Inputs

❌ Pas de table Inputs (≥ 2 fichiers lus) → agent charge trop ou devine
❌ L3 et L4 mélangés sans colonne Couche → modèle ne sait pas quoi internaliser vs traiter
❌ `SCHEMA.md` entier → 3K+ tokens gaspillés. Toujours `### \`<type>\`` (1 section, grep l'ancre)
❌ `relations_map.yaml` entier → ~3600 tokens. Toujours `grep "<slug>" DB/relations_map.yaml`
❌ `graph.json` → 121KB, overflow garanti. Toujours `GRAPH_REPORT.md` (4.6KB)
❌ Memory complet → 2 entrées récentes suffisent (récent en haut)

## Process — granularité

❌ Trop gros : "charger le contexte, mettre à jour les fichiers et valider" = 1 étape
✅ Atomique : 1 verbe + 1 cible + 1 critère de fait = 1 étape. La même action décomposée = 3 étapes.

❌ Vague : "traiter le fichier", "mettre à jour la mémoire si nécessaire"
✅ Précis : "prépendre `### 2026-07-23 — <titre>` dans `memory/sessions.md`"

❌ Branchement implicite : "si besoin", "au cas où", "éventuellement"
✅ Déterministe : "Si `last_scanned_commit` absent → scan complet (étape 3b). Si présent → git diff (étape 2)."

## Routing

❌ Section Routing présente pour un skill scope unique → bruit inutile
✅ Section Routing seulement si le skill a ≥ 2 scopes différents avec des actions différentes

❌ Routing sans fallback explicite → ambiguïté non résolue = comportement imprévisible
✅ Toujours une ligne "rien ne matche → lire GOUVERNANCE.md#routing, proposer avant d'agir"

## Outputs

❌ "Mettre à jour les fichiers concernés" → vague, non auditable
❌ Rapport absent → l'appelant ne sait pas ce qui s'est passé
❌ Rapport : "N fichiers écrits" si le skill n'écrit rien (load-project, briefing) → format cassé
✅ Table fichier/action/format + rapport `[SKILL] scope | écrit: N | lu: M | OK`

## Budget

❌ Charger tous les memory/* avant de savoir ce dont on a besoin
❌ Budget jamais vérifié sur un scope projet ou vault (peut dépasser 8K)
✅ `python3 _APP/context-budget.py <scope>` si scope > feature — avant de charger quoi que ce soit

## FK / frontmatter

❌ `client: "[[slug]]"` (singulier) → checker rouge immédiat
❌ `[[slug]]` non quoté → checker rouge immédiat
❌ `projets:` dans memory feature → pollution `projet.decisions` ← feature (downlinks parasites)
❌ `type: scan_log` sans l'ajouter à `VALID_TYPES` → checker rouge
✅ Pluriel array + guillemets + champs SCHEMA.md uniquement

## Escalade

❌ Décider seul d'un nouveau type vault → governance drift non tracé
❌ Supprimer/renommer en masse sans confirmation → irréversible
❌ Committer rouge (--no-verify) → bypass du gate obligatoire, interdit
❌ 3 échecs de validation → continuer à corriger soi-même → déposer #erreur-capture et signaler
✅ Doute → proposer + attendre "oui" explicite de Hippo

## Memory persistante

❌ Pas de section Memory dans un skill avec état entre runs → données perdues ou non structurées
❌ Memory > 10KB sans rollup → warning checker, dette qui s'accumule
✅ `memory/<fichier>.md` déclaré, format `### YYYY-MM-DD`, rollup à 10KB vers `memory/archive/`

## Vérification

❌ Aucun scénario de vérification → impossible de savoir si le skill fonctionne après refactoring
❌ Scénarios sans critère de fait ("ça marche") → non testable
✅ ≤ 3 scénarios : nominal + edge case + erreur, chaque scénario avec critère observable
