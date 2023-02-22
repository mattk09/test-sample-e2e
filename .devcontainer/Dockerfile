FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

USER root

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    lldb

USER vscode

# RUN wget -q -O - https://dot.net/v1/dotnet-install.sh | bash -s -- --version 7.0.2 --install-dir /home/vscode/.local/bin
