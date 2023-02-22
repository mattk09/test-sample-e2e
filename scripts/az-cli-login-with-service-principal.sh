#!/usr/bin/env bash

set -eo pipefail

if [[ -z "$AZURE_CREDENTIALS" ]]; then
  echo "AZURE_CREDENTIALS not set"
  exit 1
fi

az login --service-principal \
    --username $(echo $AZURE_CREDENTIALS | jq .clientId --raw-output) \
    -p $(echo $AZURE_CREDENTIALS | jq .clientSecret --raw-output) \
    --tenant $(echo $AZURE_CREDENTIALS | jq .tenantId --raw-output)
