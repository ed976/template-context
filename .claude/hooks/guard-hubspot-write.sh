#!/usr/bin/env bash
# PreToolUse hook (matched sur l'outil Bash) — garde-fou avant tout appel HubSpot en shell.
# Lit le JSON de l'event sur stdin, inspecte tool_input.command.
#   - POST/PATCH vers hubapi.com/automation/* : bloque si le payload n'a pas "isEnabled": false
#   - DELETE vers /crm/v3/properties/*        : bloque systématiquement
# exit 2 = bloque l'appel et remonte le message sur stderr. exit 0 = laisse passer.
set -euo pipefail

INPUT="$(cat)"
COMMAND="$(echo "$INPUT" | jq -r '.tool_input.command // empty')"

if [ -z "$COMMAND" ]; then
  exit 0
fi

# DELETE sur des propriétés : toujours bloqué.
if echo "$COMMAND" | grep -qiE '(-X[[:space:]]*|--request[[:space:]]+)DELETE' \
  && echo "$COMMAND" | grep -qE 'hubapi\.com.*/crm/v3/properties/'; then
  echo "BLOQUÉ: suppression de propriété HubSpot interdite via ce hook (DELETE /crm/v3/properties/)." >&2
  exit 2
fi

# POST/PATCH vers un endpoint /automation/ : exige isEnabled: false dans le payload.
if echo "$COMMAND" | grep -qiE '(-X[[:space:]]*|--request[[:space:]]+)(POST|PATCH)' \
  && echo "$COMMAND" | grep -qE 'hubapi\.com.*/automation/'; then
  if ! echo "$COMMAND" | grep -qE '"isEnabled"[[:space:]]*:[[:space:]]*false'; then
    echo "BLOQUÉ: écriture sur /automation/ sans \"isEnabled\": false explicite dans le payload. Tout flow doit être créé en dry-run (désactivé)." >&2
    exit 2
  fi
fi

exit 0
