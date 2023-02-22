#!/usr/bin/env bash

npm install -g azure-functions-core-tools@4

# https://learn.microsoft.com/en-us/dotnet/core/diagnostics/
# https://github.com/dotnet/diagnostics
# Default location is $HOME/.dotnet/tools
dotnet tool install --global dotnet-trace
dotnet tool install --global dotnet-counters
dotnet tool install --global dotnet-dump
dotnet tool install --global dotnet-gcdump
dotnet tool install --global dotnet-monitor
dotnet tool install --global dotnet-stack
dotnet tool install --global dotnet-symbol
dotnet tool install --global dotnet-sos

dotnet tool list --global

echo "dotnet - $(dotnet --version)"
echo "node - $(node --version)"
echo "npm - $(npm --version)"
echo "func - $(func --version)"

az --version

# Install sos for lldb debugging
dotnet-sos install
cat /home/vscode/.lldbinit
