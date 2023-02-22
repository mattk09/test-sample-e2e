@description('Name of the key vault (must be valid).')
param name string = resourceGroup().name

@description('Location of the key vault.')
param location string = resourceGroup().location

@description('Additional secrets to inject into the key vault.')
@secure()
// This default is only to show the structure of the object so we can disable the lint error.
// Any real secrets should be passed in and not hardcoded
#disable-next-line secure-parameter-default
param additionalSecrets object = {
  secrets: [
    {
      name: 'example-secret-guid'
      secret: 'sampleSecret'
    }
  ]
}

@description('Admin User ObjectId.')
param admindUserObjectId string = ''

var keyVaultName = toLower(take(replace(name, '_', ''), 24))
var keyVaultSku = {
  family: 'A'
  name: 'standard'
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enabledForDeployment: false
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: false
    enableSoftDelete: false
    sku: keyVaultSku
  }
}

@description('This is the built-in key vault administrator role. See https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#key-vault-administrator')
resource keyVaultAdministratorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: resourceGroup()
  name: '00482a5a-887f-4fb3-b363-3b7fe8e74483'
}

resource adminRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(admindUserObjectId)) {
  name: guid(subscription().id, resourceGroup().id, admindUserObjectId, keyVaultAdministratorRoleDefinition.id)
  scope: keyVault
  properties: {
    roleDefinitionId: keyVaultAdministratorRoleDefinition.id
    principalId: admindUserObjectId
    principalType: 'User'
  }
}

resource keyVault_additionalSecrets_items 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = [for i in range(0, length(additionalSecrets.secrets)): {
  name: '${keyVault.name}/${additionalSecrets.secrets[i].name}'
  properties: {
    value: additionalSecrets.secrets[i].secret
  }
}]

output keyVaultName string = keyVault.name
output id string = keyVault.id
