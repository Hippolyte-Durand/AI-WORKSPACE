---
name: planning-vault-project
description: Use when the user has a new project idea for the PHYT'S Obsidian vault and wants it brainstormed then organized as Projet/Feature/Tâche notes — triggers on "nouveau projet", "creer moi un projet", "organise ça en projet", or any request to turn an idea into tracked project notes in the vault
---

# Planning Vault Project

## Overview

Turns a raw idea into a brainstormed, approved design, then into
`Projet` → `Feature` → `Tâche` notes following the vault's Project Board
convention (`type`/`statut`/`priorite`/`parent` frontmatter). The brief and
plan live in the body of the main project note itself — not a separate spec
file buried elsewhere.

**REQUIRED SUB-SKILL:** Use superpowers:brainstorming for step 1. Do not
skip its approval gate — nothing gets created in the vault before the human
partner has said yes to a design.

Scope: planning artifacts only. If the approved design needs actual code,
that is a separate follow-up (e.g. writing-plans + a repo) — this skill's
job ends at the notes.

## When to Use

- User describes a new idea/project for their vault and wants it organized.
- User asks to break something into "features et tâches".

Not for: editing an existing project's notes (just edit them directly), or
pure code tasks with no vault-tracking need.

## Process

1. **Brainstorm** (superpowers:brainstorming). Classify the path, ask
   clarifying questions, propose approach, present design, get explicit
   approval. Do not proceed to step 2 without a yes.
2. **Name the project** — short noun phrase, becomes the folder name:
   `Projets/<Nom Projet>/`.
3. **Write the main note** at `Projets/<Nom Projet>/<Nom Projet>.md` — see
   Frontmatter and Body Template below. This note carries the full brief
   and plan inline, not a link to an external doc.
4. **Create one note per Feature** at
   `Projets/<Nom Projet>/Related/<Nom Feature>/<Nom Feature>.md`,
   `parent: "[[<Nom Projet>]]"`.
5. **Create one note per Tâche** in the same Feature folder:
   `Projets/<Nom Projet>/Related/<Nom Feature>/<Code> - <Nom Tâche>.md`,
   `parent: "[[<Nom Feature>]]"` (`Code` = short id like `A1`, `B2`, groups
   tasks visually by feature when sorted).
6. If `Projets/<Nom Projet>/` is (or sits inside) a git repo, `git add -A`
   and commit. Otherwise skip — most vault notes aren't versioned.
7. **During implementation**, keep the notes current as work actually
   happens (see Keeping Status Current below) — don't leave everything
   `À faire` while the real work moves on elsewhere.

## Keeping Status Current

Scope stays planning-only, but the notes must reflect reality as
implementation (done elsewhere — code, writing-plans, whatever) progresses:

- A Tâche is done → its note: `statut: Terminé`, `date_fin: <today>`.
- All of a Feature's Tâches are `Terminé` → the Feature note: `statut:
  Terminé`, `date_fin: <today>`.
- All Features are `Terminé` → the Projet note: `statut: Terminé`,
  `date_fin: <today>`.
- Work starts on something still `À faire` → flip it to `statut: En
  Cours` (and set `date_debut` if still blank) before touching it.

Update the note the same turn the underlying task is actually finished —
not batched at the end. Commit the change if the project folder is a git
repo (same as step 6).

## Frontmatter (Project Board convention)

Every note (Projet, Feature, Tâche) uses this exact schema — fields present
even when empty:

```yaml
---
type: Projet   # or Feature, or Tache
statut: À faire   # À faire | En Cours | Terminé
priorite: Moyenne   # Haute | Moyenne | Basse — never leave blank
date_debut:
date_fin:
date_echeance:
parent: "[[Nom de la note parente]]"   # blank only for the root Projet
documentation:
runbook:
---
```

- `statut`: new items are always `À faire` unless already done.
- `priorite`: assign for real — Haute for anything blocking other
  features/tasks, Moyenne default, Basse for polish/docs.
- `parent`: wikilink to the Projet for a Feature, to the Feature for a
  Tâche. Root Projet has no parent.
- `documentation`/`runbook`: leave blank unless there's an actual doc/repo
  path to point at.

## Body Template — Main Project Note

The Projet note's body (below the frontmatter) IS the brief and plan —
write it out, don't just summarize and link elsewhere:

```markdown
<One-paragraph pitch: what this is and why.>

## Contexte
<Why this project exists now.>

## Objectifs
- <goal 1>
- <goal 2>

## Non-objectifs
- <explicitly out of scope for v1>

## Approche
<Architecture/approach agreed during brainstorming, a few paragraphs.>

## Découpage Features → Tâches
- **<Feature 1>** — <one-line purpose>
  - <Code> <task 1>
  - <Code> <task 2>
- **<Feature 2>** — <one-line purpose>
  - ...
```

Feature and Tâche note bodies stay short (1-3 lines: what it covers), same
as existing vault notes — the detail lives in the Projet note's plan
section above, not duplicated per note.

## Common Mistakes

- Creating notes before the brainstorming approval gate — always get the
  yes first.
- Leaving `priorite` blank — pick one, it drives the board's sort/color.
- Writing the brief into a separate `docs/` file and only linking it from
  the Projet note — the brief belongs in the note body itself.
- Forgetting the `parent` link — without it the note is orphaned in the
  Project Board tree view.
