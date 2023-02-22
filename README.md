# Introduction

This project is meant to be a general starting point for most common dotnet projects.  It provides boiler plate code for basic core engineering fundamentals, like observability, testing, security, and CI/CD.

Depending on your project needs, you may not need all the components or pieces included, perhaps, others may be missing.  However, this should give you a great foundation to begin with.

## Project Features

- net 7.0 WebApi
- functions v4 in net 7.0 isolated process
- CI/CD (yaml)
  - Build
  - Analyzers
    - AnalysisMode: AllEnabledByDefault
    - StyleCop
  - Test
  - Code Coverage (coverlet)
  - Release
    - Uses [GitHub Actions][github-actions]
    - Deploys Azure resources
- Swagger using [NSwag][swagger-nswag]
  - [Swashbuckle][swagger-swashbuckle] is another alternative
  - Navigate to `/swagger` endpoint to view

## Best Practices

- [Naming Conventions][naming]
- [Secret Management][developer-secret-management] during development

## Getting Started

### Tools needed

- [dotnet 7.0][dotnet-install] - `curl -sSL https://dot.net/v1/dotnet-install.sh | bash`
- [az cli][az-cli] - `curl -L https://aka.ms/InstallAzureCli | bash`

Note: If you use [Visual Studio Code](https://code.visualstudio.com/) for development, this repo has a preconfigured [dev container](https://code.visualstudio.com/docs/devcontainers/containers) with everything you need.

### GitHub Actions

For a successful deployment from GitHub Actions, you will need to [connect to azure](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure?) using a service principal or workload identity federation.  This can be setup one time via a script and then have the relevant credentials added to both Actions/Codespace secrets in your [GitHub Secrets][github-secrets].

#### Service Prinicipal

A [service principal](https://learn.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli#1-create-a-service-principal) can be created from the command line by following [these steps](/docs/service-principal.md) in bash with az cli.

#### Workload Identity Federation

TODO

## Feature Details

### Storage

This project should automatically fetch the Azure Storage Account connection string from Key Vault.  The `RequestLoggerController` is very simple example of to read/write/delete from that storage.  Local development can enable the simulator from configuration to use an in-memory table for testing.  Just set "Features:UseStorageSimulator" to `true`.

[Storage Explorer][storage-explorer] is a great cross-platform utility to help interact with storage accounts during development.

### Functions

Local development can also enable an in-memory simulator like storage.  Just set "Features:UseFunctionsSimulator" to `true`.

### Configuration

It is not always easy to see in the code, but this project gains a lot from using the [Host.CreateDefaultBuilder][dotnet-configuration-default-builder].  Here is how configuration works out of the box:

- Set the ContentRootPath to the result of GetCurrentDirectory()
- Load host IConfiguration from "DOTNET_" prefixed environment variables
- Load app IConfiguration from 'appsettings.json' and 'appsettings.{*EnvironmentName*}.json'
- Load app IConfiguration from User Secrets when EnvironmentName is 'Development' using the entry assembly
- Load app IConfiguration from environment variables
- Configure the ILoggerFactory to log to the console, debug, and event source output
- Enables scope validation on the dependency injection container when EnvironmentName is 'Development'

### Docker

This project comes docker enabled (but not required).  Running in docker is a good way to avoid cluttering your machine with dev tools and frameworks

Building a local image can be done with:

```bash
# Build a local image
docker build -t sample-webapi:local -f ./docker/sample-webapi/Dockerfile .

# Run that image and detch
docker run --publish=8081:80 --rm --detach --name sample-webapi-container sample-webapi:local

# Test it
curl http://localhost:8081/healthcheck

# Stop container
docker stop sample-webapi-container
```

Bring up all the services with [docker-compose][docker-compose]

```bash
docker-compose build
docker-compose up
```

Once everything is up, you can find the useful services (configured in [docker-compose.yml](./docker-compose.yml))

| Service | Local Url | Description
|---|---|---|
| WebApi | http://localhost:8081/ | Our Sample.WebApi |
| Functions | http://localhost:8082/ | Our Sample.Functions |
| [Prometheus][prometheus] | http://localhost:9090/ | [CNCF][cncf] project for metrics |
| [Grafana][grafana] | http://localhost:3000/ | [CNCF][cncf] project for building and viewing dashboards |
| [Jaeger][jaeger] | http://localhost:16686/ | [CNCF][cncf] project for visualizing distributed tracing |

[naming]: https://docs.microsoft.com/en-us/dotnet/standard/design-guidelines/naming-guidelines
[developer-secret-management]: https://docs.microsoft.com/en-us/aspnet/core/security/app-secrets
[code-coverage]: https://docs.microsoft.com/en-us/azure/devops/pipelines/ecosystems/dotnet-core
[dotnet-configuration]: https://docs.microsoft.com/en-us/aspnet/core/fundamentals/configuration/
[dotnet-configuration-default-builder]: https://docs.microsoft.com/en-us/dotnet/api/microsoft.extensions.hosting.host.createdefaultbuilder
[dotnet-install]: https://docs.microsoft.com/en-us/dotnet/core/tools/dotnet-install-script#examples
[dotnet-host-tracing]: https://github.com/dotnet/runtime/blob/main/docs/design/features/host-tracing.md

[swagger-nswag]: https://docs.microsoft.com/en-us/aspnet/core/tutorials/getting-started-with-nswag
[swagger-swashbuckle]: https://docs.microsoft.com/en-us/aspnet/core/tutorials/getting-started-with-swashbuckle
[storage-explorer]: https://azure.microsoft.com/en-us/features/storage-explorer/
[github-actions]: https://docs.github.com/en/actions/learn-github-actions/understanding-github-actions
[github-secrets]: https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository
[az-cli]: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli

[docker-compose]: https://docs.docker.com/compose/reference/up/
[prometheus]: https://prometheus.io/
[grafana]: https://grafana.com/
[jaeger]: https://www.jaegertracing.io/
[cncf]: https://www.cncf.io/
