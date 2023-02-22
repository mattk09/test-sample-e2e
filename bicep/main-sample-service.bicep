@description('Base name of all resources (invalid characters will be stripped when required).')
param name string = resourceGroup().name

@description('Optional objectId to grant an identity access to the key vault.')
param developerObjectIdKeyVaultAccessPolicy string = ''

@description('Location of all resources.')
param location string = resourceGroup().location

@description('Additional secrets to inject into the key vault.')
@secure()
param additionalSecrets object = {
  secrets: [
    {
      name: 'example-secret-guid'
      secret: newGuid()
    }
  ]
}

@description('Storage Account SKU')
param storageAccountSku string = 'Standard_LRS'

var functionsAppName = '${name}-functions'

module appServicePlan 'modules/app-service-plan.bicep' = {
  name: 'appServicePlan'
  params: {
    name: name
    location: location
  }
}

module storageAccount 'modules/storage-account.bicep' = {
  name: 'storageAccount'
  params: {
    name: name
    location: location
    storageAccountSku: storageAccountSku
    usePrivateEndpoint: false
    keyVault: keyVault.outputs.keyVaultName
  }
}

module applicationInsights 'modules/application-insights.bicep' = {
  name: 'applicationInsights'
  params: {
    name: name
    location: location
    keyVault: keyVault.outputs.keyVaultName
  }
}

var devAccessPolicy = {
  objectId: developerObjectIdKeyVaultAccessPolicy
  principalType: 'User'
  canWrite: true
}

var webAppAccessPolicy = {
  objectId: webApp.outputs.webAppPrincipalId
  principalType: 'ServicePrincipal'
  canWrite: false
}

var functionsAccessPolicy = {
  objectId: functionsApp.outputs.functionsAppPrincipalId
  principalType: 'ServicePrincipal'
  canWrite: true
}

module keyVault 'modules/key-vault.bicep' = {
  name: 'keyVault'
  params: {
    name: name
    location: location
    additionalSecrets: {
      secrets: concat([
      ], additionalSecrets.secrets)
    }
  }
}

module keyVaultRoles 'modules/key-vault-roles.bicep' = {
  name: 'keyVaultRoles'
  params: {
    name: keyVault.outputs.keyVaultName
    additionalAccessPolicies: [
      devAccessPolicy
      functionsAccessPolicy
      webAppAccessPolicy
    ]
  }
}

module functionsApp 'modules/functions.bicep' = {
  name: 'functionsService'
  params: {
    name: functionsAppName
    location: location
    appServicePlanName: appServicePlan.outputs.appServicePlanName
    keyVaultNameForConfiguration: keyVault.outputs.keyVaultName
    storageAccountName: storageAccount.outputs.storageAccountName
    applicationInsightsName: applicationInsights.outputs.applicationInsightsName
  }
}

module webApp 'modules/app-service.bicep' = {
  name: 'appService'
  params: {
    location: location
    appServicePlanName: appServicePlan.outputs.appServicePlanName
    keyVaultNameForConfiguration: keyVault.outputs.keyVaultName
    functionsAppHostName: functionsApp.outputs.functionsAppDefaultHostName
  }
}


output storageAccountName string = storageAccount.outputs.storageAccountName
output keyVaultName string = keyVault.outputs.keyVaultName
output storageEndpoint object = storageAccount.outputs.storageEndpoint
output webAppName string = webApp.outputs.webAppName
output webAppEndpoint string = 'https://${webApp.outputs.webAppDefaultHostName}/'
output webAppHealthCheckEndpoint string = 'https://${webApp.outputs.webAppDefaultHostName}/healthcheck'
output functionsAppName string = functionsApp.outputs.functionsAppName
output functionsAppHealthCheckEndpoint string = 'https://${functionsApp.outputs.functionsAppDefaultHostName}/api/healthcheck'
