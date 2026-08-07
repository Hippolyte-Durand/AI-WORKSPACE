# Rubrique de risque — split-module

## Formule de score

```
score = min(lines / 250, 1.0) * 0.4
      + min(len(import_domains) / 3, 1.0) * 0.4
      + (1.0 - internal_call_density) * 0.2
```

Clamp final : 0.0 → 1.0

## Seuils

| Score | Flag | Action |
|---|---|---|
| ≥ 0.7 | 🔴 danger | Split prioritaire |
| 0.4–0.7 | 🟡 warning | Surveiller, plan si > 400 lignes |
| < 0.4 | ✅ ok | Ne pas toucher |
| SST | 🔷 sst | Importé par ≥ 3 fichiers ET density > 0.4 → SST cohérente, déconseillé |

## Exemples concrets (plugin hippo-command-center)

| Fichier | Lignes | Domaines | Density | Score | Flag |
|---|---|---|---|---|---|
| `src/main.ts` | ~580 | 5+ (cards/*, store, data, obsidian, node) | ~0.3 | ~0.87 | 🔴 danger |
| `src/data.ts` | ~420 | 2 (obsidian, types internes) | ~0.6 | ~0.52 | 🟡 warning |
| `src/store.ts` | ~310 | 4 (obsidian, data, util, node:fs) | ~0.5 | ~0.61 | 🟡 warning |
| `src/skillsData.ts` | ~140 | 2 | ~0.7 | ~0.31 | ✅ ok |
| `src/util.ts` | ~60 | 1 | ~0.9 | ~0.08 | 🔷 sst |

## Pourquoi ces 3 métriques

**Lignes (40%)** : proxy de complexité. Un fichier de 500 lignes dépasse la fenêtre d'attention efficace d'un LLM sur une tâche locale. Seuil 250 = 1 écran de contexte dense.

**Import domains (40%)** : indicateur de responsabilités mélangées. Un fichier qui importe depuis `./cards/*` + `obsidian` + `node:fs` + `./store` fait du render + de l'I/O + de l'orchestration = 3 responsabilités distinctes.

**Internal call density (20%)** : cohésion interne. Si les fonctions d'un fichier ne s'appellent pas entre elles, elles n'ont probablement rien à faire ensemble. Density faible = fragments indépendants déguisés en fichier.

## Faux positifs courants

- **Fichier index/barrel** : beaucoup d'imports + exports, peu de logique → score élevé mais rôle légitime. Vérifier manuellement si le fichier ne contient que des re-exports.
- **Fichier de types** : beaucoup de `interface`/`type`, peu de fonctions → density faible mais cohérent. Les types d'un même domaine vont ensemble.
- **Entry point** : `main.ts` plugin a naturellement de nombreux imports. Peut légitimement avoir score élevé si sa seule responsabilité est d'enregistrer des handlers.

## Règle 1 fichier = 1 fonction métier = 1 output

Le test le plus simple et le plus fiable :

**"Ce fichier fait quoi ?"**

| Réponse | Verdict |
|---|---|
| "Transforme les données vault en ProjectRow[]" | ✅ 1 chose → ok |
| "Render le tab Projets" | ✅ 1 chose → ok |
| "Charge les données ET render l'UI ET gère les events" | ❌ 3 choses → 3 fichiers |
| "Gère les actions queue ET les mails ET le calendrier" | ❌ 3 sources de données → 3 fichiers |

**Output = ce que le fichier produit :**
- Données transformées (array, object, Record) → `data-*.ts`
- DOM muté → `render-*.ts` ou `cards/*.ts`
- Side-effect fichier (read/write JSON) → `store-*.ts`
- Événements / listeners → `events-*.ts`

Si un fichier produit 2 types d'output différents → violation, splitter.

**Exemple plugin :**
```
main.ts produit : DOM (render tabs) + listeners (vault events) + plugin registration
→ 3 outputs → split en :
  view.ts        → render uniquement
  event-bus.ts   → listeners + debounce
  main.ts        → plugin entry (register view + command) seulement
```

## Critère de décision final (toujours LLM)

Le score est un **filtre**, pas un verdict. Le LLM lit le fichier et répond à :
1. Ces fonctions ont-elles une raison d'être dans le même fichier ?
2. Un développeur qui cherche X saura-t-il naturellement aller dans ce fichier ?
3. Si on modifie A, y a-t-il un risque non-évident de casser B dans le même fichier ?

3× non → splitter. 2× oui → laisser.
