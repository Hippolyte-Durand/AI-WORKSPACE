# Format de section memory (capture)

Toute entrée dans un fichier memory commence par ce header, inséré **en haut du corps** (après le frontmatter).

```markdown
### YYYY-MM-DD — <Titre court>
```

---

## sessions.md

```markdown
### YYYY-MM-DD — <Titre court>

**✅ Fait**
- <action concrète> → <résultat>
- …

**⏭️ Suite**
- <prochaine action atomique>
- …
```

---

## decisions.md

```markdown
### YYYY-MM-DD — <Décision>

**Choix** : <ce qui a été décidé>
**Pourquoi** : <raison principale>
**Rejeté** : <alternative écartée> — <raison>
```

---

## apprentissages.md

```markdown
### YYYY-MM-DD — <Ce qui a été appris>

**Appris** : <constat, principe, découverte>
**Change** : <ce que ça modifie dans la façon de travailler>
```

---

## blocages.md

```markdown
### YYYY-MM-DD — <Symptôme>

**Symptôme** : <ce qui bloque>
**Résolution** : <fix appliqué ou "en cours">
**statut** : ouvert | résolu
```

---

## evals.md (projet uniquement, jamais feature)

```markdown
### YYYY-MM-DD — Eval

**Note** : N/5
**Bien** : <ce qui a bien marché>
**Raté** : <ce qui n'a pas marché>
**Règle** : <principe à retenir>
```

---

**Règles invariantes**
- Date = aujourd'hui (`YYYY-MM-DD`), jamais relative
- Section en **haut** du corps (après frontmatter), pas en bas
- Bump `maj:` dans le frontmatter à chaque écriture
- `features:` seul comme FK dans feature-memory (jamais `projets:`)
- `projets:` seul comme FK dans projet-memory
