---
name: schema-drawio-propre
description: Produire un fichier draw.io (.drawio) d'architecture ou de flux propre du premier coup — layout lisible, groupes conteneurs, flux numéroté, routing manuel sans croisements, légende, palette cohérente. Utiliser dès qu'on crée ou modifie un diagramme draw.io / .drawio d'architecture, de flux, de réseau ou de système.
---

# Schéma draw.io propre (archi / flux)

## Inputs

| Fichier | Couche | Sections | Pourquoi |
|---|---|---|---|
| Ce skill (règles + palette embarquées) | L3 | tout | contraintes visuelles à internaliser |
| `CCBH-architecture.drawio` | L3 | style | référence palette + routing (stable) |
| Description tâche (prompt) | L4 | tout | périmètre du diagramme à produire |
| Fichier `.drawio` existant si modification | L4 | tout | artefact à transformer |

But : un `.drawio` propre **du premier coup** — la propreté visuelle compte autant que l'exactitude. Appliquer TOUTES ces règles d'emblée (chacune = un aller-retour de correction évité).

## Règles

1. **Groupes = vrais conteneurs.** `container=1;collapsible=0` + enfants `parent="<grp-id>"` à géométrie **relative** au groupe. Jamais de box flottantes posées dans un rectangle (sinon déplacer une zone laisse les box derrière). Fond légèrement teinté par zone, bordure `dashed=1`, titre en haut (`verticalAlign=top;fontStyle=1;spacingTop=8`).
2. **Layout = sens du flux, gauche→droite.** Une zone par acteur (client → serveur → cloud → infra). Pas de zigzag.
3. **Numéroter le flux principal** ①②③… sur les labels d'edge (`fontStyle=1`).
4. **Distinguer les liens :** trait plein = requête synchrone ; `dashed=1` = async / secrets / refresh. Colorer les edges transverses (`strokeColor` = couleur de la source).
5. **Edges → une box précise, jamais un groupe.** Cibler un groupe = flèche floue sur le bord du conteneur.
6. **Router les edges longs à la main** pour éviter de traverser les zones : `exitX/exitY/entryX/entryY` + waypoints `<Array as="points"><mxPoint .../></Array>`. Utiliser les corridors vides entre groupes (vertical) et les marges haut/bas (horizontal). Coord absolue d'un enfant = origine_groupe + géométrie_relative.
7. **Légende obligatoire** (bas, container) : styles de trait (plein/pointillé) + code couleur des nœuds.
8. **Titre texte dans le canvas** (haut, centré, `fontSize=16;fontStyle=1`) — pas seulement le nom d'onglet `<diagram name=...>`, invisible à l'export PNG.
9. **Couvrir le périmètre réel,** pas juste le happy path (ex. « créer ET détruire » → label « provision / destroy »).
10. **Page dimensionnée** large (`pageWidth/pageHeight`) pour loger légende + marges de routing.

## Palette cohérente

- bleu `#dae8fc` / `#6c8ebf` — client / web
- vert `#d5e8d4` / `#82b366` — backend
- orange `#ffe6cc` / `#d79b00` — secrets
- rouge `#f8cecc` / `#b85450` — cloud / CI
- violet `#e1d5e7` / `#9673a6` — infra
- jaune `#fff2cc` / `#d6b656` — données

Référence validée : `CCBH-architecture.drawio` (vault Obsidian, `PROJECTS/ci-cd-builder-hyperv/maquettes/`).
