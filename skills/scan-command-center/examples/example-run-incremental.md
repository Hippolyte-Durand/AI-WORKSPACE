# Exemple — run incrémental (delta 2 fichiers)

## Situation
`last_scanned_commit: a1ff021`. HEAD = `b3c8d92`.

## Commandes git
```bash
git log -1 --format=%h -- .obsidian/plugins/hippo-command-center
# → b3c8d92

git diff --name-only a1ff021..b3c8d92 -- .obsidian/plugins/hippo-command-center/src
# → src/cards/contactPicker.ts
#    src/store.ts
```

## Séquence
1. Delta = 2 fichiers → pas de "à jour", on continue.
2. Lire GRAPH_REPORT.md (incrémental graphify si disponible).
3. Lire `src/cards/contactPicker.ts` + `src/store.ts` SEULEMENT.
4. Mettre à jour les sections correspondantes dans CODEMAP.md.
5. **Ne pas toucher** aux 21 autres sections.
6. Prépendre ligne log + mettre à jour `last_scanned_commit`.

## Sections mises à jour — exemple

```markdown
### src/store.ts
Data boundary : interface types (QueueItem, Mail, CalEvent, DashboardData). loadDashboardData() orchestre en 1 shot : readJsonArray(action-queue.json) + readJsonArray(mail.json) + buildVaultIndex(app), filtre tickets actifs. Mutations (tous async) : dismissQueueItem, setProjectStatut, setTicketStatus (frontmatter update via processFrontMatter), linkContactToProject, createContact (from template + frontmatter), appendLink (helper bidir symétrie contact↔projet). JSON stores : data/{action-queue.json, mail.json}.
```

```markdown
### src/cards/contactPicker.ts
FuzzySuggestModal : liste unlinked contacts (type:contact, byType index lookup). Items [{ kind: "create" }, ...contacts]. getItemText(), onChooseItem() → ContactPickerModal.open(). CreateContactModal (form name input + buttons Enter/Escape). linkContactToProject/createContact (store mutations). Gère cycle de vie des modales. Side-effect : symétrie bidir immédiate (contact.projets + projet.contacts).
```

## Ligne log ajoutée

```markdown
| 2026-07-24 | b3c8d92 | src/store.ts, src/cards/contactPicker.ts | ajout linkContactToProject + createContact + appendLink (bidir) ; nouveau contactPicker FuzzyModal |
```

## Rapport conversation
```
[SCAN] b3c8d92 | 2 fichiers delta | src/store.ts + src/cards/contactPicker.ts | OK
```
