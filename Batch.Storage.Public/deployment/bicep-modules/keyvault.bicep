// Bicep module to provision a Key Vault
// -----------------------------------------------------
@description('Location for Key Vault')
param keyVaultLocation string

@description('Name of Key Vault')
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
