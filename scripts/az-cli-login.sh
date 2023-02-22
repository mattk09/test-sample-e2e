#!/usr/bin/env bash

set -o pipefail

az account show

if [[ 0 != $? ]]; then
  set -e
  az login
fi

# If you have multiple subscriptions select the one you prefer to deploy into
# az account set --subscription "Your Subscription Name" or "AZURE_SUBSCRIPTION_ID"
