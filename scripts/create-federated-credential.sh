#!/usr/bin/env bash

set -euo pipefail

AZURE_SUBSCRIPTION_ID="$1"
SERVICE_PRINCIPAL_ID="$2"

# Current branch would be $(git rev-parse --abbrev-ref HEAD)
BRANCH="main"

az ad app federated-credential create --id "$SERVICE_PRINCIPAL_ID" --parameters \
'{
    "name": "federated-azure-credential",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:'${ORGANIZATION_NAME}'/'${REPOSITORY_NAME}':ref:refs/heads/'${BRANCH}'",
    "description": "Deploy to Azure from '${BRANCH}' branch",
    "audiences": [
        "api://AzureADTokenExchange"
    ]
}'
