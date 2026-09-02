---
name: cloture-incident
description: Use when the user wants to close a PHYT'S helpdesk ticket and make the change visible on the Kanban board — triggers on "cloture ce ticket", "clôturer l'incident", "passer le ticket en terminé", "/cloture-incident". Takes a delivery mode argument, "direct" (commit, fast-forward main, push) or "pr" (push branch, open a pull request); asks which one when the user has not said.
---

# Clôture d'incident (vault PHYT'S)

## Overview

Closes a ticket in the `TICKETS` repo: updates the ticket note's frontmatter and
body to reflect the resolution, then delivers the commit to the ref the Kanban
board reads.

The single most important fact about this workflow: **the board reads a git ref,
never the disk.** A ticket edited locally and not pushed is closed for nobody.
Editing the note is half the job; delivery is the other half.

## Arguments

The skill takes one argument, the delivery mode:

- `direct` — commit on the current branch, fast-forward `main`, push `origin main`.
- `pr` — commit, push the working branch, open a pull request with `gh pr create`.

If the user invoked the skill without a mode, ask which one before touching git.
Do not guess. Suggest `pr` when the repo is shared with a colleague and `direct`
when the user is working alone on their own branch.

## Steps

### 1. Locate the ticket note

A ticket is a folder in the `TICKETS` repo, `Titre du ticket (NNNN)/`, holding
the card `Titre du ticket (NNNN).md` — same name as its folder — plus the
attachments: exports, screenshots, logs, quotes.

That naming is load-bearing. The board's server (`TOOLS/KANBAN-PHYTS`) falls
back to the enclosing folder as a card's `parent` when the frontmatter does not
declare one, and only cards **without** a parent get a column. A note carrying
its folder's own name is exempt — `estNoteDeDossier` in
`server/hierarchie.mjs` — so it stays a root card. Rename either the card or
its folder and they stop matching: the card becomes a task of a card that does
not exist, and silently leaves the board.

Other `.md` files in the folder are attachments and must **not** carry a
`statut` field, or they turn into phantom cards.

`find . -name "*NNNN*"` is the reliable lookup; ticket names contain
apostrophes and accents that break naive globbing.

### 2. Gather what actually happened

Ask the user what was done, unless they already said it in the invocation. Do
not invent resolution detail: fabricated steps in a ticket note become false
history in the vault.

For anything genuinely unknown but needed for a complete record — name of the
requester, date of the original request, asset inventory number, licence
assigned — do not silently drop it. Add a `## Reste à faire` section listing the
gaps as explicit follow-ups.

### 3. Edit the card

Frontmatter:

- `statut: Terminé` (exact accented value — the board groups on this string;
  the other values in use are `Backlog` and `En Cours`)
- `date_fin:` the closure date, ISO `YYYY-MM-DD`

Body — the card follows the Incident template, sections in this order:
`## Constat`, `## Impact`, `## Diagnostic`, `## Résolution`, and optionally
`## Reste à faire`.

- Rewrite `## Impact` in the past tense; a closed ticket describes what the
  outage cost, not what it is costing.
- `## Résolution` states what was configured, installed, or delivered, and to
  whom. Numbered steps when the fix is reproducible on another machine.
- Keep the prose in French, normal register — these notes are read by
  colleagues.

Read a already-closed ticket in the repo first as a model for tone and depth.

### 3bis. Gate — no unresolved gap ships silently

Before touching git, re-read the finished `## Résolution` and scan it for:

- any `<placeholder>` left unfilled (poste ID, compte, licence, SSID, nom...).
- a vague stand-in for a person ("l'utilisateur du service concerné",
  "le demandeur") where a real name belongs.
- an item also listed in `## Reste à faire` that `## Résolution` claims as
  done — the two must not contradict each other.

Any hit found: **list every gap explicitly to the user and stop.** Do not
commit with placeholders "for now" and do not silently push the gaps into
`Reste à faire` as a way to close anyway — closing with known holes is a
choice the user makes, not a default. Only proceed to step 4 once the user
has supplied the missing data or explicitly said to close with the gaps
left open (in which case `Reste à faire` carries them, stated plainly).

This gate is what step 2's "do not silently drop it" was already asking
for — it just makes the check impossible to skip on a later ticket.

### 4. Deliver

Stage only what belongs to the ticket. Editor and tool droppings
(`excalidraw.log` and friends) belong in `.gitignore`, never in a ticket commit.

Commit message: Conventional Commits, French, subject `feat(ticket): cloturer le
ticket NNNN`. Body explains the resolution and names any gaps left in
`Reste à faire`.

**Mode `direct`:**

```
git checkout main
git merge --ff-only <branche>
git push origin main
```

Before merging, run `git log --oneline main..<branche>` and report every commit
the merge will carry onto `main` — closing a ticket often drags along unrelated
work already sitting on the branch, and the user must see that before it lands
on the board's ref.

Listing those commits is not enough: **read what each one changes** before
merging. A tidy-looking refactor sitting on the branch is exactly how a layout
change once reached `main` and emptied the board. Run `git show --stat <sha>`
on anything that touches card locations or frontmatter, and say plainly what it
will do to the board.

If the merge is not a fast-forward, stop and hand it back rather than forcing a
merge commit the user did not ask for.

**Mode `pr`:**

```
git push -u origin <branche>
gh pr create --base main --title "..." --body "..."
```

The board only updates once the PR is merged. Say so explicitly — otherwise the
user waits on a card that will not move.

### 5. Report

State the ref that was updated and the commit range that was pushed, confirm the
card should now appear in the **Terminé** column, and list any follow-ups left in
`Reste à faire`.

## Do not

- Push without the user's go-ahead, in either mode.
- Write a resolution the user did not describe.
- Change `statut` on an attachment note — only the card carries it.
- Rename a card or its folder without renaming the other.
- Merge a branch commit onto `main` without having read what it changes.
- Treat a local edit as a closed ticket.
- Commit a `## Résolution` that still holds a `<placeholder>` or an unnamed
  stand-in without having flagged it to the user first (step 3bis).

## Quand le board est vide

The parent rule fails silently: nothing errors, the card simply is not in any
column. Two causes, in order of likelihood.

1. **The running server is stale.** It is a plain `node server/server.mjs`
   process serving `TOOLS/KANBAN-PHYTS` from the working tree — it does not
   reload. A pulled fix only takes effect on restart. Say so rather than
   changing the vault to suit an old binary.
2. **A card no longer matches its folder name**, so the folder fallback made it
   a task of a nonexistent card.

To check without disturbing the user's instance, serve the vault on a spare
port and read the API — cards appear under `features`, each with `project`,
`status` and `parent`:

```sh
node server/server.mjs ~/Documents/PHYTS --port 4179 --ref main
curl -s http://127.0.0.1:4179/api/init
```

A healthy ticket card shows `parent: null` and `type: "feature"`. Stop the
spare server when done.
