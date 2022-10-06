// Bicep module to provision a Key Vault
// -----------------------------------------------------
@description('Location for Function App')
param keyVaultLocation string

@description('Name of Function App')
param keyVaultName string

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: keyVaultLocation
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    accessPolicies: []
  }
}
