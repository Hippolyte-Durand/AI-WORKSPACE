# Exemple — section fichier dans CODEMAP.md

Format de référence. Reproduire cette densité et ce style pour chaque fichier scanné.

---

## Fichier utilitaire simple (1 ligne)

```markdown
### src/util.ts
Helpers vault I/O : openFile (réuse side-leaf split pane vertical, fallback openLinkText), readJsonArray/writeJsonArray (wrapper app.vault.adapter ± empty []), dataPath const.
```

---

## Fichier logique moyenne complexité (2–3 lignes)

```markdown
### src/store.ts
Data boundary : interface types (QueueItem, Mail, CalEvent, DashboardData). loadDashboardData() orchestre en 1 shot : readJsonArray(action-queue.json) + readJsonArray(mail.json) + buildVaultIndex(app), filtre tickets actifs. Mutations (tous async) : dismissQueueItem, setProjectStatut, setTicketStatus (frontmatter update via processFrontMatter), linkContactToProject, createContact (from template + frontmatter). JSON stores : data/{action-queue.json, mail.json}.
```

---

## Fichier entrée plugin complexe (3–4 lignes)

```markdown
### src/main.ts
Entrée plugin : enregistre CommandCenterView (ItemView) + ribbon/command. Classe CommandCenterView maintient activeTab + selectedProject + cache VaultIndex (invalidé au changement vault, debounced 1s). Render complet à chaque nav/filter (dashboard 4-KPI tiles + 2-col layout, projets/tickets kanban avec drag-move, contacts/sources/wiki/infra/skills/insights tabs). Écoute metadataCache+vault events. Exports : CommandCenterPlugin (default), constantes tabs/VIEW_TYPE.
```

---

## Card pure render (1–2 lignes)

```markdown
### src/cards/calendar.ts
"Agenda du jour" card : render CalEvent[] (time, title, end, cal). Line 1 time badge + title (cliquable → openCalendar). Line 2 meta (end + cal name). Pure render.
```

---

## Checklist qualité d'une section
- [ ] Nomme le pattern (SGBD-md layer, pure render, data boundary, fuzzy modal…)
- [ ] Liste les exports/types clés avec noms exacts
- [ ] Mentionne les dépendances internes si non-triviales
- [ ] Mentionne les side-effects (I/O, DOM, Chart.js, clipboard) ou dit "Pure render"
- [ ] Pas d'article, pas de phrase "ce fichier fait X"
- [ ] ≤ 4 lignes
