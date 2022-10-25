// Bicep module to provision a Key Vault
// -----------------------------------------------------
@description('Location for the Key Vault')
param keyVaultLocation string

@description('Name of the Key Vault')
param keyVaultName string

@description('Indicate if Key Vault has public access or not')
param publicNetworkAccess bool = true

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
    publicNetworkAccess: publicNetworkAccess ? 'Enabled' : 'Disabled'
  }
}

output id string = keyVault.id
