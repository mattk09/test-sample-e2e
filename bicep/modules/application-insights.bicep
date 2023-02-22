// This is pre santized in the parent
@description('Base name for Application Insights.')
param name string = resourceGroup().name

@description('Location for theApplication Insights.')
param location string = resourceGroup().location

@description('Key Vault name to store connection string')
param keyVault string = ''

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

module optionalKeyVaultStorage 'key-vault-secret.bicep' = if (!empty(keyVault)) {
  name: 'applicationInsights-keyVaultSecret'
  params: {
    keyVault: keyVault
    name: 'ApplicationInsights--InstrumentationKey'
    secret: applicationInsights.properties.InstrumentationKey
  }
}

output applicationInsightsName string = applicationInsights.name
