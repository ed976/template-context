---
name: create-hubspot-workflow
description: Crée un flow (workflow) HubSpot via l'API Automation v4, toujours en dry-run.
disable-model-invocation: true
---

# create-hubspot-workflow

Procédure pour créer un flow via l'API Automation v4. Le flow est toujours créé
désactivé (`isEnabled: false`) — l'activation est une étape humaine, jamais faite
par l'agent (règle dure #4).

## Étapes (ordre obligatoire)

1. **Recon des records concernés.**
   Identifier via `scripts/hs` (GET) quels records (companies) seraient dans le
   périmètre du flow tel qu'envisagé : filtres, propriétés impliquées, volumétrie
   approximative.

2. **Formuler la requête de vérification AVANT de construire le flow.**
   Écrire explicitement la requête (endpoint + filtres) qui permettra plus tard de
   vérifier que le flow, une fois activé par un humain, se comporte comme prévu.
   Cette requête est documentée avant la construction du JSON, pas après.

3. **Construire le JSON du flow.**
   `isEnabled: false` doit être explicite dans le payload — jamais omis, jamais
   `true`. Respecter les conventions de `context/domain/naming.md` pour le nom
   du flow.

4. **Écrire la définition.**
   Sauvegarder dans `definitions/flows/<nom>.json` — source de vérité versionnée,
   à créer avant tout appel API.

5. **Appliquer via scripts/hs.**
   `./scripts/hs POST /automation/v4/flows "$(cat definitions/flows/<nom>.json)"`
   Jamais de curl ad hoc (règle dure #6). Le hook `guard-hubspot-write.sh` reconnaît
   l'appel `scripts/hs POST|PATCH /automation/...` (arguments positionnels, pas une
   URL) et bloquera tout appel sans `"isEnabled": false` explicite dans le payload.

6. **Ne jamais activer.**
   L'agent ne bascule jamais `isEnabled` à `true`, ni via l'API ni via l'UI.

7. **Signaler à l'utilisateur.**
   Une fois le flow créé en dry-run, indiquer clairement qu'il est prêt pour
   relecture et activation manuelle dans l'UI HubSpot — donner le nom du flow et
   le chemin de sa définition.

## Interdits

- Ne jamais construire le flow avant d'avoir formulé la requête de vérification (étape 2).
- Ne jamais créer un flow avec `isEnabled: true` ou sans le champ.
- Ne jamais activer un flow, même sur demande implicite.
