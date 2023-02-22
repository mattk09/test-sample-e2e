#!/usr/bin/env bash

set -euo pipefail

AZURE_SUBSCRIPTION_ID="$1"
SERVICE_PRINCIPAL_NAME="$2"

# Create the service-principal with contributor role over your subscription
# Note: you can limit it down to a specific resource group for tighter access control
# Take this output for your GitHub secret and save as 'AZURE_CREDENTIALS'

# use filter for exact match instead of display-name which is a startsWith
SERVICE_PRINCIPAL_QUERY_RESULT=$(az ad app list --filter "displayname eq '$SERVICE_PRINCIPAL_NAME'")
EXISTING_SERVICE_PRINCIPAL_COUNT=$(echo $SERVICE_PRINCIPAL_QUERY_RESULT | jq '. | length')

if [[ $EXISTING_SERVICE_PRINCIPAL_COUNT == 1 ]]; then
  echo "App already exists" >&2
  echo $SERVICE_PRINCIPAL_QUERY_RESULT | jq '.[0].appId' --raw-output
elif [[ $EXISTING_SERVICE_PRINCIPAL_COUNT > 1 ]]; then
  echo "Multiple apps exist, verify what is going on"
  exit 1
else
  echo "No app, creating..." >&2

  AZURE_CREDENTIALS=$(az ad sp create-for-rbac \
      --name "$SERVICE_PRINCIPAL_NAME" \
      --role contributor \
      --scopes /subscriptions/$AZURE_SUBSCRIPTION_ID)

  echo $AZURE_CREDENTIALS | jq '.appId' --raw-output
fi
