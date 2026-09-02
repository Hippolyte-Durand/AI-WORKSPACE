---
name: cloture-preparation-poste
description: Use when the user wants to close a PHYT'S GLPI ticket for a "préparation / configuration de poste" request and needs the exact output text to paste into GLPI. Triggers on "clôture cette demande de préparation de poste", "clôture ce ticket poste", "config poste terminée", "/cloture-preparation-poste".
---

# Clôture d'une demande de préparation de poste (GLPI)

## Overview

Produces the closing text to paste into GLPI ("Ajouter une solution", see
[GLPI - Convention de saisie](../../../Documents/PHYTS/WIKI-KB/Documentations/GLPI%20-%20Convention%20de%20saisie.md))
when a poste-preparation ticket is done. This is output generation, not a
technical how-to — the full checklist and format live in
[GLPI - Clôture préparation de poste](../../../Documents/PHYTS/WIKI-KB/Documentations/GLPI%20-%20Clôture%20préparation%20de%20poste.md).
Read that file for the current format before generating output — it is the
source of truth, this skill does not duplicate it.

## Steps

1. Read the reference doc above for the current output format and checklist.
2. Ask the user for whatever fields are missing among: n° de poste, nom/rôle
   de l'utilisateur, compte Outlook, SSID Wi-Fi (si plusieurs sites), nom du
   responsable qui réceptionne. Do not invent a value — an unconfirmed field
   left blank is safer than a guessed one.
3. If the user states an item was **not** done or not applicable (e.g. no
   partage réseau requis), drop that line rather than marking it OK.
4. Produce the filled block in the exact format from the reference doc, ready
   to paste into GLPI.
5. Remind the user this goes under "Ajouter une solution" to actually close
   the ticket — "Répondre" alone does not close it.

## Do not

- Invent a poste ID, account name, or responsible's name not given by the user.
- Mark a checklist line done without the user confirming it.
- Duplicate the checklist/format here — always read it fresh from the
  Documentations file so the two never drift.
