# Checklist — création d'un nouveau skill

## 3 questions avant de créer

1. **Ça doit exister ?** Intention récurrente réelle, pas spéculative (YAGNI). Si "au cas où" → ne pas créer.
2. **C'est déjà là ?** Vérifier `.claude/commands/` + `.claude/agents/` + skills système. Adapter > créer.
3. **Impact irréversible ?** Si le skill écrit/supprime des fichiers → lister, confirmer avec Hippo.

---

## Choisir : fichier unique ou dossier

| Cas | Structure |
|---|---|
| Skill simple, 1 output, pas d'exemples | `.claude/commands/<skill>.md` (fichier unique) |
| Output formaté complexe, exemples utiles, anti-patterns | `.claude/commands/<skill>/` (dossier) |

Structure dossier :
```
.claude/commands/<skill-name>/
  <skill-name>.md        ← contrat ICM (obligatoire)
  anti-patterns.md       ← format interdit/autorisé (si output formaté)
  examples/              ← exemples de référence L3 (si output complexe)
    example-<cas-A>.md
    example-<cas-B>.md
  output/                ← templates de sortie réutilisés
    <template>.md
  memory/                ← état persistant entre runs (si skill stateful)
    <fichier>.md
```

---

## Checklist SKILL.md section par section

### Frontmatter
- [ ] `description:` une ligne, verb + objet + résultat, ≤ 120 chars, routing L1

### Mission
- [ ] 1–3 lignes, critère de succès visible, pas de "peut"/"pourrait"
- [ ] Trigger explicite (`/nom` ou signal naturel décrit)

### Routing *(si multi-scope)*
- [ ] Supprimer la section si skill scope unique
- [ ] Table signal → scope → action
- [ ] Précédence feature > projet > client > vault
- [ ] Fallback explicite si rien ne matche
- [ ] Parse `$ARGUMENTS` en priorité, sinon `_STATE.md`

### Inputs
- [ ] Table si ≥ 2 fichiers lus (obligatoire)
- [ ] Colonne Couche remplie (L3 / L4) sans mélange
- [ ] Colonne Sections avec ancre `#section`, jamais fichier entier
- [ ] Anti-bloat listé : SCHEMA.md (1 section), relations_map (grep), graph.json (interdit), memory (2 entrées)

### Process
- [ ] Étape 1 : budget si scope > feature (`context-budget.py`)
- [ ] Chaque étape : 1 verbe + 1 cible + 1 critère de fait
- [ ] Aucune étape > 1 action ("charger ET mettre à jour" → 2 étapes)
- [ ] Branchements déterministes (Si A → X exact, Si B → Y exact)
- [ ] Pas de "si nécessaire", "au besoin", "éventuellement"
- [ ] Validation en avant-dernière étape, rapport en dernière

### Outputs
- [ ] Table fichier / action / format
- [ ] Format sections datées (`### YYYY-MM-DD — Titre`)
- [ ] Validation ordre : `strict-validation.py` → `check-vault-integrity.py`
- [ ] Rapport conversation : `[SKILL] scope | écrit: N | lu: M | OK`
- [ ] Rapport adapté si skill sans écriture (load-*, briefing → `lu: M`)

### Memory *(si stateful)*
- [ ] Supprimer la section si skill sans état persistant
- [ ] Déclarer `memory/<fichier>.md` + ce qu'on y stocke
- [ ] Règle rollup 10KB mentionnée

### Vérification
- [ ] ≤ 3 scénarios : nominal + edge case + erreur
- [ ] Chaque scénario : condition initiale + critère observable
- [ ] Scénario erreur : 0 écriture parasite confirmée

### Escalade
- [ ] Table situation → action
- [ ] "Validation échoue 3×" → #erreur-capture
- [ ] Défaut absolu : proposer, ne pas exécuter

---

## Après création

```bash
# Obligatoire
python3 _APP/check-vault-integrity.py   # 0 erreur

# Si le skill crée des notes typées
python3 _APP/strict-validation.py
```

Test rapide du skill créé : simuler le scénario nominal (§Vérification) et vérifier le critère de fait.
