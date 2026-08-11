#!/bin/bash
# Statusline home-made (repo-owned) — badges des modes caveman + ponytail.
# Remplace les scripts des plugins : source unique = ai-workspace, zéro
# dépendance à ~/.claude/plugins/cache. Les 2 modes sont actifs par défaut
# (activés au SessionStart par modes-activate.sh) → badges statiques.
# ponytail: statique, pas de suivi de niveau ni de flag toggle. Si besoin de
#           refléter "stop caveman"/niveaux, lire un flag ~/.claude/.caveman-active.
printf '\033[38;5;172m[CAVEMAN]\033[0m \033[38;5;108m[PONYTAIL]\033[0m'
