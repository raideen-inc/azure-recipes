// Bicep module to provision an Internet accessible Storage Account

@description('Location for the Storage Account')
param storageLocation string

@description('Name of the Storage Account')
param storageName string

// Found out a list of SKU: https://docs.microsoft.com/en-us/rest/api/storagerp/srp_sku_types 
@allowed([
  'Standard_LRS'
  'Standard_ZRS'
  'Standard_GZRS'
])
@description('Pricing/Sizing tier of the Storage Account')
param storageSku string

@description('Indicate if Storage Account has public access or not')
param publicNetworkAccess bool = true

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: storageName
  location: storageLocation
  sku: {
    name: storageSku
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    publicNetworkAccess: publicNetworkAccess ? 'Enabled' : 'Disabled'
    allowBlobPublicAccess: publicNetworkAccess
    accessTier: 'Hot'
    minimumTlsVersion: 'TLS1_2'
  }
}

output storageAccountName string = storageAccount.name
output id string = storageAccount.id
