#!/usr/bin/env bash

set -euo pipefail

AZURE_SUBSCRIPTION_ID="$1"
SERVICE_PRINCIPAL_ID="$2"
ROLE_NAME="$3"

ROLE_DEFINITION=$(cat <<EOF
{
  "name": "$ROLE_NAME",
  "description": "Ability to assign roles",
  "actions": ["Microsoft.Authorization/roleAssignments/write"],
  "DataActions": [],
  "NotDataActions": [],
  "NotActions": ["Microsoft.Authorization/*/Delete"],
  "AssignableScopes": ["/subscriptions/$AZURE_SUBSCRIPTION_ID"]
}
EOF
)

ROLE_DEFINITION_QUERY_RESULT=$(az role definition list --custom-role-only --name "$ROLE_NAME")
ROLE_DEFINITION_COUNT=$(echo $ROLE_DEFINITION_QUERY_RESULT | jq '. | length')

if [[ "$ROLE_DEFINITION_COUNT" != 0 ]]; then
  echo "Role with name '$ROLE_NAME' already exists"
  az role definition list --custom-role-only --name "$ROLE_NAME"
else
  az role definition create --role-definition "$ROLE_DEFINITION"
fi

az role assignment create --assignee "$SERVICE_PRINCIPAL_ID" --role "$ROLE_NAME"
