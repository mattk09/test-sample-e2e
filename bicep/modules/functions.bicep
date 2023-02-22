@description('Base name for the functions service.')
param name string = resourceGroup().name

@description('Location for the functions service.')
param location string = resourceGroup().location

@description('AppServicePlan name for the functions service to run under.')
param appServicePlanName string

@description('Name of the Key Vault to use for configuration.')
param keyVaultNameForConfiguration string

@description('Name of Storage Acount.')
param storageAccountName string

@description('Name of Application Insights.')
param applicationInsightsName string

@description('The language worker runtime to load in the function app.')
@allowed([
  'dotnet'
  'node'
  'python'
  'java'
  'dotnet-isolated'
])
param functionWorkerRuntime string = 'dotnet-isolated'

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightsName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName
}

var storageAccountConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value}'

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' existing = {
  name: appServicePlanName
}

resource functionsApp 'Microsoft.Web/sites@2022-03-01' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'functionapp,linux'
  properties: {
    serverFarmId: appServicePlan.id
    reserved: true
    httpsOnly: true
    siteConfig: {
      netFrameworkVersion: 'v7.0'
      healthCheckPath: 'api/healthcheck'
      linuxFxVersion: 'DOTNET-ISOLATED|7.0' // `az functionapp list-runtimes --os linux -o table` for more options
      appSettings: [
        {
          // I would prefer this comes from KeyVault, but the functions runtime consumes this before KV can be applied right now
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'AzureWebJobsStorage'
          value: storageAccountConnectionString
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: functionWorkerRuntime
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'KeyVaultNameFromDeployment'
          value: keyVaultNameForConfiguration
        }
        {
          name: 'AzureWebJobsSecretStorageType'
          value: 'keyvault'
        }
        {
          name: 'AzureWebJobsSecretStorageKeyVaultUri'
          value: 'https://${keyVaultNameForConfiguration}${environment().suffixes.keyvaultDns}/'
        }
        {
          name: 'TelemetryProvider'
          value: 'None' // Error when using app insights right now
        }
      ]
    }
  }
}

output functionsAppName string = functionsApp.name
output functionsAppDefaultHostName string = functionsApp.properties.defaultHostName
output functionsAppPrincipalId string = functionsApp.identity.principalId

