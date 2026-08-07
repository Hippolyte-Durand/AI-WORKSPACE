# Usine logicielle — cycle dev par défaut

Squelette : cycle Addy Osmani (pack `agent-skills`, vendored dans `ai-workspace/skills/`).
Ce fichier est la règle **par défaut** pour tout développement logiciel, quel que soit le CLI. Les instructions projet (CLAUDE.md/AGENTS.md de repo) et la doctrine vault primeront toujours sur ce fichier en cas de conflit de scope.

## Le cycle

```
DEFINE → PLAN → BUILD → VERIFY → REVIEW → SHIP
 /spec    /plan   /build   /test     /review   /ship
```

| Phase | Skill | Gate de sortie |
|---|---|---|
| DEFINE | `spec-driven-development` | spec écrite, exigence non ambiguë |
| PLAN | `planning-and-task-breakdown` | tâches atomiques, ordonnées, critères d'acceptation |
| BUILD | `incremental-implementation` + `test-driven-development` | slice verticale, test-first, commit par tâche |
| VERIFY | `test-driven-development` + `debugging-and-error-recovery` | tests + build verts, preuve (pas « seems right ») |
| REVIEW | `code-review-and-quality` | revue 6 axes (dont over-engineering) passée |
| SHIP | `shipping-and-launch` + `git-workflow-and-versioning` | checklist pré-lancement, rollback possible |

Skills d'appui : `security-and-hardening`, `performance-optimization`, `code-simplification`, `api-and-interface-design`, `documentation-and-adrs`, `observability-and-instrumentation`, `ci-cd-and-automation`, `deprecation-and-migration`, `doubt-driven-development` (enjeux élevés / code inconnu), `source-driven-development` (décisions framework sourcées).

## Règles

1. **Toute tâche dev non-triviale suit le cycle.** Trivial (typo, one-liner, config) → direct, pas de cérémonie.
2. **Spec avant code** dès que l'exigence est ambiguë, nouvelle, ou cross-modules. Sinon → PLAN direct.
3. **BUILD = slices verticales.** Une tâche = implémenter + tester + vérifier + committer. `/build auto` autorisé une fois le plan approuvé (retire le pas-à-pas humain, pas la vérification).
4. **Pas de merge sans REVIEW.** Revue 6 axes, findings par sévérité, format terse (`L42: severity problème. fix.`).
5. **Pas de SHIP sans preuve** : tests + build verts, story de vérification documentée.
6. **Dérogations explicites** : prototype jetable (skill `prototype`), exploration/recherche, notes et travail vault (doctrine vault à la place).

## Notes multi-CLI

- Les commands `/spec` `/plan` `/build` `/test` `/review` `/ship` `/code-simplify` = **Claude only**. Kimi et Antigravity : invoquer les skills directement par nom (ex. `/spec-driven-development`).
- Personas Claude (subagents) : `code-reviewer`, `test-engineer`, `security-auditor`.
- Le méta-skill `using-agent-skills` route vers le bon skill si doute.

## Outils transverses (usine)

Au-delà du cycle : `triage` (issues → briefs agent-ready) · `git-guardrails-claude-code` (bloque git destructeur) · `improve-codebase-architecture` (scan → rapport HTML) · `split-module` (audit + découpe + build gate) · `setup-ts-deep-modules` (dependency-cruiser) · `prototype` (spike jetable, dérogation au cycle) · `resolving-merge-conflicts` · `release` · `handoff` / `claude-handoff` (passation contexte) · `wizard` (setup guidé humain).

## Domaines voisins (hors usine)

Les skills sont rangés par thème dans `ai-workspace/skills/` :

- **`usine-logiciel/`** — ce cycle (backbone Addy + outils transverses).
- **`agent-engineering/`** — construire des agents/pipelines LLM (context, memory, evaluation, multi-agent, `tool-design`, `project-development`). **Domaine peer**, pas le cycle SE — invoqué à part.
- **`vault/`** · **`writing/`** · **`design/`** · **`comms/`** — autres domaines.

Les CLIs voient tous les skills **à plat** (`/nom`) ; le rangement par thème est côté source.
