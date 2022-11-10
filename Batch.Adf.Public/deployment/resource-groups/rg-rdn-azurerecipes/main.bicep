@description('Location for the deployment')
param location string = resourceGroup().location

@allowed([
  'dev'
  'test'
  'prod'
])
@description('Short Name to identify the environment')
param environmentName string

@allowed([
  'Standard_LRS'
  'Standard_ZRS'
])
@description('Pricing/Sizing tier of the Storage Account')
param storageSku string

@description('Pricing/Sizing tier of the Function App Storage Account')
param repoConfiguration object

// Generate an unique value for naming the deployment
@description('String for uniqueness')
param unqiueUtc string = utcNow()

// Generate Azure Service name for different environment
var appName = 'batch'
var orgAbbr = 'demo'
var adfName = 'adf-${orgAbbr}-${appName}-${environmentName}'
var storageName = 'st${orgAbbr}${appName}${environmentName}'

// Provision Data Factory for Public Batch
module adf '../../bicep-modules/data-factory.bicep' = {
  name: '${adfName}-${unqiueUtc}'
  params:{
    dataFactoryLocation: location
    dataFactoryName: adfName
    publicNetworkAccess: true
    dataFactoryRepoConfig: repoConfiguration
  }
}

// Provision Storage Account for ADF Batch
module storageAcct '../../bicep-modules/storage-account.bicep' = {
  name: '${storageName}-${unqiueUtc}'
  params:{
    storageLocation: location
    storageName: storageName
    storageSku: storageSku
    publicNetworkAccess: true
    blobContainers: [
      'raw'
      'cruated'
    ]
  }
}

// Grant blob data contributor role to the Func App managed identity
module roleAssignStorage '../../bicep-modules/storage-account-role-assign.bicep' = {
  name: '${storageName}role-${unqiueUtc}'
  params: {
    storageAcctName: storageName
    principalId: adf.outputs.managedIdentityId
    roleName: 'BlobDataOwner'
  }
  dependsOn: [
    adf
    storageAcct
  ]
}
