FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build-env

COPY ./src /src
COPY .editorconfig /src

RUN cd /src/Sample.Functions && \
    mkdir -p /home/site/wwwroot && \
    dotnet publish *.csproj --output /home/site/wwwroot

# Build runtime image
# To enable ssh & remote debugging on app service change the base image to the one below
# FROM mcr.microsoft.com/azure-functions/dotnet:4-appservice
FROM mcr.microsoft.com/azure-functions/dotnet-isolated:4-dotnet-isolated7.0
ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true \
    AzureWebJobsSecretStorageType=files

ADD ./docker/sample-functions/host.json /azure-functions-host/Secrets/host.json

COPY --from=build-env /home/site/wwwroot /home/site/wwwroot
