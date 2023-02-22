#!/usr/bin/env bash

set -o pipefail

gh auth status

if [[ 0 != $? ]]; then
  set -e
  gh auth login
fi
