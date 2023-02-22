#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)

# Login to azure with credentials to modify azure active directory
$SCRIPT_DIR/az-cli-login.sh

# Login to github to set secrets to connect to azure from actions
$SCRIPT_DIR/gh-cli-login.sh

# Set repo level variables
source $SCRIPT_DIR/exports.sh

AZURE_SUBSCRIPTION_ID=$(az account show --query "id" --output tsv)

SERVICE_PRINCIPAL_ID=$($SCRIPT_DIR/create-service-principal.sh "$AZURE_SUBSCRIPTION_ID" "$SERVICE_PRINCIPAL_NAME")

echo "Using service principal: $SERVICE_PRINCIPAL_ID"
echo "Create/Assign role: $ROLE_NAME"
$SCRIPT_DIR/create-and-assign-role.sh "$AZURE_SUBSCRIPTION_ID" "$SERVICE_PRINCIPAL_ID" "$ROLE_NAME"

echo "Adding federated credential"
$SCRIPT_DIR/create-federated-credential.sh "$AZURE_SUBSCRIPTION_ID" "$SERVICE_PRINCIPAL_ID"

echo "Adding secrets and variables to GitHub"
$SCRIPT_DIR/gh-set-azure-credentials-secret.sh "$AZURE_SUBSCRIPTION_ID" "$SERVICE_PRINCIPAL_ID"
