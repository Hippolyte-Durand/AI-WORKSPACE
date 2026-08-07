# Patterns de split sûrs

## 1. Barrel re-export (pattern principal)

La règle absolue : **aucun import existant ne doit casser**.

```typescript
// AVANT : tout dans store.ts
export function loadDashboardData() { ... }
export function dismissQueueItem() { ... }
export interface QueueItem { ... }

// ÉTAPE 1 : créer queue.ts
export interface QueueItem { ... }
export function dismissQueueItem() { ... }

// ÉTAPE 2 : dans store.ts, re-exporter
export { QueueItem, dismissQueueItem } from "./queue";
// loadDashboardData reste dans store.ts

// RÉSULTAT : tous les imports existants `from "./store"` continuent de fonctionner
// ÉTAPE 3 (optionnelle plus tard) : migrer les imports directs vers "./queue"
```

## 2. Séparer types et logique

Fichiers mixant interfaces + fonctions → séparer `types.ts` en priorité.

```typescript
// types.ts — zéro logique, zéro import sauf types externes
export interface ProjectRow { ... }
export interface TicketRow { ... }
export type Statut = "en cours" | "terminé" | "bloqué";

// data.ts — importe types, contient la logique
import type { ProjectRow, TicketRow } from "./types";
```

Avantage : `types.ts` change rarement → le LLM n'a pas besoin de le lire pour modifier la logique.

## 3. Séparer render et données

Fichiers qui font `fetch() + transform() + render()` → 3 fichiers distincts.

```
data.ts      → fetch + transform (pur, pas de DOM)
renderer.ts  → render (DOM only, pas de fetch)
index.ts     → orchestre (importe les deux, re-export public API)
```

## 4. Dépendances circulaires

Si A importe B et B importe A → créer `shared.ts` avec les types/constantes partagés.

```
AVANT : main.ts ← store.ts ← main.ts  (circulaire)

APRÈS :
  shared.ts  → types communs (QueueItem, VaultIndex)
  store.ts   → importe shared.ts (pas main.ts)
  main.ts    → importe store.ts + shared.ts
```

## 5. Naming des nouveaux fichiers

- Un fichier = un sujet en kebab-case : `event-handlers.ts`, `date-utils.ts`
- Pas de suffixes génériques : ~~`utils2.ts`~~, ~~`helpers-new.ts`~~
- Si le fichier réexporte → son nom = le domaine public : `queue.ts` (pas `queue-internal.ts`)
- Max 200-250 lignes cible. > 300 = suspect.

## 6. Ce qu'on ne split PAS

- Fichier SST cohérent (importé par > 3 fichiers, call graph dense) → risque de régression > bénéfice
- Fichier < 150 lignes mono-responsabilité → overhead inutile
- Fichier de configuration (`esbuild.config.mjs`, `tsconfig.json`) → jamais
