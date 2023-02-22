#!/usr/bin/env bash

set -euo pipefail

AZURE_SUBSCRIPTION_ID="$1"
SERVICE_PRINCIPAL_ID="$2"

AZURE_AUTH_CREDENTIALS=$(az ad sp credential reset --years 2 --id "$SERVICE_PRINCIPAL_ID")

# Convert to AZURE_CREDENTIALS format which is expected by the github azure action
# https://github.com/marketplace/actions/azure-login#configure-a-service-principal-with-a-secret
AZURE_CREDENTIALS=$(echo $AZURE_AUTH_CREDENTIALS | jq --arg AZURE_SUBSCRIPTION_ID "$AZURE_SUBSCRIPTION_ID" '{clientId: .appId, clientSecret: .password, tenantId: .tenant, subscriptionId: $AZURE_SUBSCRIPTION_ID}')

gh secret set AZURE_CREDENTIALS --body "$AZURE_CREDENTIALS"
gh secret set AZURE_DEVELOPER_OBJECT_ID --body "$(az ad signed-in-user show | jq .id --raw-output)"
gh secret set TEST_SECRET --body "not a real secret"

function set_repository_variable()
{
  NAME="$1"
  VALUE="$2"
  HEADER_ACCEPT="Accept: application/vnd.github+json"
  HEADER_VERSION="X-GitHub-Api-Version: 2022-11-28"

  set +e
  gh api \
    --method POST \
    --header "$HEADER_ACCEPT" \
    --header "$HEADER_VERSION" \
    "/repos/$ORGANIZATION_NAME/$REPOSITORY_NAME/actions/variables" \
    --field name="$NAME" \
    --field value="$VALUE" \
    --silent

  RESULT="$?"
  set -e

  if [[ "$RESULT" == "1" ]]; then
    gh api \
      --method PATCH \
      --header "$HEADER_ACCEPT" \
      --header "$HEADER_VERSION" \
      "/repos/$ORGANIZATION_NAME/$REPOSITORY_NAME/actions/variables/$NAME" \
      --field name="$NAME" \
      --field value="$VALUE"
  fi
}

set_repository_variable "AZURE_CLIENT_ID" "$(echo $AZURE_AUTH_CREDENTIALS | jq '.appId' --raw-output)"
set_repository_variable "AZURE_TENANT_ID" "$(echo $AZURE_AUTH_CREDENTIALS | jq '.tenant' --raw-output)"
set_repository_variable "AZURE_SUBSCRIPTION_ID" "$AZURE_SUBSCRIPTION_ID"
set_repository_variable "SERVICE_PRINCIPAL_NAME" "$SERVICE_PRINCIPAL_NAME"

gh api -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" "/repos/$ORGANIZATION_NAME/$REPOSITORY_NAME/actions/variables"
