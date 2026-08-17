#!/usr/bin/env bash
# PreToolUse hook (matched sur l'outil Bash) — garde-fou avant tout appel HubSpot en shell.
# Lit le JSON de l'event sur stdin, inspecte tool_input.command.
#   - POST/PATCH vers /automation/*     : bloque si le payload n'a pas "isEnabled": false
#   - DELETE vers /crm/v3/properties/*  : bloque systématiquement
# Deux formes de commande sont reconnues :
#   1. scripts/hs <MÉTHODE> <PATH> [BODY]  — cas nominal (règle dure #6 du CLAUDE.md)
#   2. curl ... hubapi.com<PATH> ...       — défense en profondeur si la règle #6
#      n'est pas respectée (curl ad hoc direct vers l'API)
# exit 2 = bloque l'appel et remonte le message sur stderr. exit 0 = laisse passer.
set -euo pipefail

INPUT="$(cat)"
COMMAND="$(echo "$INPUT" | jq -r '.tool_input.command // empty')"

if [ -z "$COMMAND" ]; then
  exit 0
fi

check_method_and_path() {
  local method="$1"
  local target_path="$2"

  if [ "$method" = "DELETE" ] && echo "$target_path" | grep -qE '^/crm/v3/properties/'; then
    echo "BLOQUÉ: suppression de propriété HubSpot interdite via ce hook (DELETE /crm/v3/properties/)." >&2
    exit 2
  fi

  if { [ "$method" = "POST" ] || [ "$method" = "PATCH" ]; } && echo "$target_path" | grep -qE '^/automation/'; then
    if ! echo "$COMMAND" | grep -qE '"isEnabled"[[:space:]]*:[[:space:]]*false'; then
      echo "BLOQUÉ: écriture sur /automation/ sans \"isEnabled\": false explicite dans le payload. Tout flow doit être créé en dry-run (désactivé)." >&2
      exit 2
    fi
  fi
}

# Forme 1 (cas nominal) : appel via scripts/hs <MÉTHODE> <PATH> [BODY], arguments
# positionnels, aucune URL complète dans la commande.
if [[ "$COMMAND" =~ scripts/hs[[:space:]]+([A-Za-z]+)[[:space:]]+([^[:space:]]+) ]]; then
  HS_METHOD="$(echo "${BASH_REMATCH[1]}" | tr '[:lower:]' '[:upper:]')"
  HS_PATH="${BASH_REMATCH[2]}"
  check_method_and_path "$HS_METHOD" "$HS_PATH"
fi

# Forme 2 (défense en profondeur) : curl ad hoc direct vers hubapi.com.
if echo "$COMMAND" | grep -qE 'hubapi\.com'; then
  CURL_METHOD="$(echo "$COMMAND" | grep -oiE '(-X[[:space:]]+|--request[[:space:]]+)[A-Za-z]+' | head -n1 | grep -oiE '[A-Za-z]+$' | tr '[:lower:]' '[:upper:]')"
  CURL_PATH="$(echo "$COMMAND" | grep -oE "hubapi\\.com[^\"'[:space:]]*" | head -n1 | sed -E 's#^hubapi\.com##')"
  if [ -n "$CURL_METHOD" ] && [ -n "$CURL_PATH" ]; then
    check_method_and_path "$CURL_METHOD" "$CURL_PATH"
  fi
fi

exit 0
