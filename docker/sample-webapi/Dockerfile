# syntax=docker/dockerfile:1
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build-env
WORKDIR /sample

COPY ./src ./src/
COPY Sample.Project.Template.sln .
COPY .editorconfig .

RUN dotnet restore

RUN dotnet publish -c Release -o build ./src/Sample.WebApi/Sample.WebApi.csproj

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:7.0
WORKDIR /sample
COPY --from=build-env /sample/build .

ENTRYPOINT ["dotnet"]
CMD ["Sample.WebApi.dll"]
