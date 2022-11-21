// Bicep module to add secerts and access to Key Vault
// -----------------------------------------------------
@description('Name of Function App')
param keyVaultName string

@description('Object Id of Managed Identity')
param managedIdentityIds array

var policies = [for principalId in managedIdentityIds: {
  objectId: principalId
  tenantId: subscription().tenantId
  permissions:{
    keys: []
    secrets: [
      'get'
      'list'
    ]
    certificates:[]
  }
}]

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName

  resource accessPolicy 'accessPolicies@2022-07-01' =  {
    name:'add'
    properties:{
      accessPolicies: policies 
    }
  }
}

