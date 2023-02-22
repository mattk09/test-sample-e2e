@description('Name of the existing key vault.')
param name string

@description('')
param additionalAccessPolicies array = []

@description('Admin User ObjectId.')
param admindUserObjectId string = ''


resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: name
}

@description('This is the built-in secret reader role. See https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#key-vault-secrets-user')
resource secretReaderRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: '4633458b-17de-408a-b874-0445c86b69e6'
}

@description('This is the built-in key vault secret officer role. See https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#key-vault-secrets-officer')
resource secretOfficerRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: resourceGroup()
  name: 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'
}

@description('This is the built-in key vault administrator role. See https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#key-vault-administrator')
resource keyVaultAdministratorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: resourceGroup()
  name: '00482a5a-887f-4fb3-b363-3b7fe8e74483'
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for i in range(0, length(additionalAccessPolicies)): {
  name: guid(subscription().id, resourceGroup().id, additionalAccessPolicies[i].objectId, (additionalAccessPolicies[i].canWrite ? secretOfficerRoleDefinition.id : secretReaderRoleDefinition.id), string(i))
  scope: keyVault
  properties: {
    roleDefinitionId: (additionalAccessPolicies[i].canWrite ? secretOfficerRoleDefinition.id : secretReaderRoleDefinition.id)
    principalId: additionalAccessPolicies[i].objectId
    principalType: additionalAccessPolicies[i].principalType
  }
}]

resource adminRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(admindUserObjectId)) {
  name: guid(subscription().id, resourceGroup().id, admindUserObjectId, keyVaultAdministratorRoleDefinition.id)
  scope: keyVault
  properties: {
    roleDefinitionId: keyVaultAdministratorRoleDefinition.id
    principalId: admindUserObjectId
    principalType: 'User'
  }
}
