@description('Name of the key vault secret (must be valid).')
param name string

@description('Secret value.')
@secure()
param secret string

@description('Name of the existing key vault (must be valid).')
param keyVault string

resource keyVaultExisting 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVault
}

resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: '${keyVaultExisting.name}/${name}'
  properties: {
    value: secret
  }
}
