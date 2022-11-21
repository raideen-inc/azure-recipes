// Bicep module to provision a Storage Account

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

@description('A list of name for creating blob container')
param blobContainers array = []

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

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = [for name in blobContainers : {
  name: '${storageAccount.name}/default/${name}'
}]

output storageAccountName string = storageAccount.name
output id string = storageAccount.id
