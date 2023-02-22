@description('Base name of all resources (invalid characters will be stripped when required).')
param name string = resourceGroup().name

@description('Optional objectId to grant an identity access to the key vault.')
param developerObjectIdKeyVaultAccessPolicy string = ''

@description('Location of all resources.')
param location string = resourceGroup().location

@description('Additional Sample Secret to inject into the key vault.')
@secure()
param additionalSampleSecret string = ''

@description('Storage Account SKU')
param storageAccountSku string = 'Standard_RAGRS'

// Build list if needed
var additionalSecrets = {
  secrets: [
    (empty(additionalSampleSecret) ? null : {
      name: 'AdditionalSampleSecret'
      secret: additionalSampleSecret
    })
  ]
}

var devAccessPolicy = {
  objectId: developerObjectIdKeyVaultAccessPolicy
  principalType: 'User'
  canWrite: true
}

module keyVault 'modules/key-vault.bicep' = {
  name: 'keyVault'
  params: {
    name: name
    location: location
    additionalSecrets: additionalSecrets
    admindUserObjectId: developerObjectIdKeyVaultAccessPolicy
  }
}

module keyVaultRoles 'modules/key-vault-roles.bicep' = {
  name: 'keyVaultRoles'
  params: {
    name: keyVault.outputs.keyVaultName
    additionalAccessPolicies: skip([
      devAccessPolicy
    ], empty(developerObjectIdKeyVaultAccessPolicy) ? 1 : 0)
  }
}

module sshKey 'modules/ssh-key.bicep' = {
  name: 'sshKeySetup'
  params: {
    name: name
    location: location
    keyVault: keyVault.outputs.keyVaultName
    sshKeySecretName: 'generated-sshkey'
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

output sshPublicKey string = sshKey.outputs.sshPublicKey
