#!/usr/bin/env bash

set -uo pipefail

SCRIPT_DIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)

# Login to azure with credentials to modify azure active directory
$SCRIPT_DIR/az-cli-login.sh

# Set repo level variables
source $SCRIPT_DIR/exports.sh

AZURE_SUBSCRIPTION_ID=$(az account show --query "id" --output tsv)

SERVICE_PRINCIPAL_QUERY_RESULT=$(az ad app list --filter "displayname eq '$SERVICE_PRINCIPAL_NAME'")
EXISTING_SERVICE_PRINCIPAL_COUNT=$(echo $SERVICE_PRINCIPAL_QUERY_RESULT | jq '. | length')

if [[ $EXISTING_SERVICE_PRINCIPAL_COUNT == 1 ]]; then
  echo "Cleaning..."
  APP_ID=$(echo $SERVICE_PRINCIPAL_QUERY_RESULT | jq '.[0].appId' --raw-output)

  az role assignment delete --assignee "$APP_ID" --role "$ROLE_NAME"
  az role definition delete --name "$ROLE_NAME"

  az ad sp delete --id "$APP_ID"
  az ad app delete --id "$APP_ID"

elif [[ $EXISTING_SERVICE_PRINCIPAL_COUNT > 1 ]]; then
  echo "Multiple apps exist, verify what is going on"
  exit 1
else
  echo "Can't find service principal"
  exit 1
fi
