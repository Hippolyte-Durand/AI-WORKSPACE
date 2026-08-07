<!-- last_scanned_commit: <HASH> -->
# CODEMAP — hippo-command-center

> Carte du code maintenue par le skill scan-command-center. Lire CE fichier au lieu des sources. Détail graphe : `graphify-out/GRAPH_REPORT.md`.

## Vue d'ensemble

<1 paragraphe : rôle du plugin, flux principal (main → store → data → cards), onglets, pattern UI. Max 5 lignes.>

## Fichiers

### src/main.ts
<résumé 2–4 lignes : entrée plugin, CommandCenterView, cache VaultIndex, tabs, events, exports>

### src/data.ts
<résumé 2–3 lignes : SGBD-md layer, buildVaultIndex, getters purs, rows typées, exclusions>

### src/store.ts
<résumé 2–3 lignes : data boundary, loadDashboardData, mutations async, JSON stores>

### src/util.ts
<résumé 1 ligne : helpers I/O, fonctions clés>

### src/skillsData.ts
<résumé 1–2 lignes : filesystem scan skills/agents, SkillsModel, loadSkills>

### src/data.selfcheck.ts
<résumé 1–2 lignes : test standalone, assertions, usage npx tsx>

<!-- src/cards/ : ordre alphabétique -->

### src/cards/actionQueue.ts
<résumé 1–2 lignes>

### src/cards/calendar.ts
<résumé 1–2 lignes>

### src/cards/components.ts
<résumé 1 ligne>

### src/cards/contactCard.ts
<résumé 1–2 lignes>

### src/cards/contactPicker.ts
<résumé 1–2 lignes>

### src/cards/contacts.ts
<résumé 1–2 lignes>

### src/cards/featuresList.ts
<résumé 1–2 lignes>

### src/cards/infra.ts
<résumé 2–3 lignes : charts Chart.js + filter + list groupé>

### src/cards/insights.ts
<résumé 1–2 lignes>

### src/cards/kanban.ts
<résumé 1–2 lignes>

### src/cards/mail.ts
<résumé 1 ligne>

### src/cards/projectDetail.ts
<résumé 2–3 lignes : dual-col Bento, KPIs, sections, ContactPickerModal>

### src/cards/projects.ts
<résumé 1–2 lignes>

### src/cards/skills.ts
<résumé 1–2 lignes>

### src/cards/sources.ts
<résumé 1–2 lignes>

### src/cards/tickets.ts
<résumé 1 ligne>

### src/cards/wiki.ts
<résumé 1–2 lignes : filter state, chips, renderList, groupé par type>

## Log des modifications

| Date | Commit | Fichiers | Résumé |
|---|---|---|---|
| YYYY-MM-DD | <hash> | <fichiers modifiés> | <résumé 1 ligne, noms exacts des fonctions ajoutées/modifiées> |
