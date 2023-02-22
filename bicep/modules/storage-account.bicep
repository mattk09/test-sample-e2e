@description('Name for the storage account.')
param name string = resourceGroup().name

@description('Location for the storage account.')
param location string = resourceGroup().location

@description('Use storage account on private network.')
param usePrivateEndpoint bool = false

@description('Key Vault name to store connection string')
param keyVault string = ''

@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
param storageAccountSku string = 'Standard_RAGRS'

var storageAccountName = toLower(take(replace(replace(name, '-', ''), '_', ''), 24))

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  kind: 'StorageV2'
  location: location
  sku: {
    name: storageAccountSku
  }
  properties: {
    minimumTlsVersion: 'TLS1_2'
    networkAcls: usePrivateEndpoint ? {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    } : null
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
  }
}

module optionalKeyVaultStorage 'key-vault-secret.bicep' = if (!empty(keyVault)) {
  name: 'storageAccount-keyVaultSecret'
  params: {
    keyVault: keyVault
    name: 'AzureStorageSettings--ConnectionString'
    secret:'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value}'
  }
}

output storageAccountName string = storageAccount.name
output storageEndpoint object = storageAccount.properties.primaryEndpoints
output id string = storageAccount.id
