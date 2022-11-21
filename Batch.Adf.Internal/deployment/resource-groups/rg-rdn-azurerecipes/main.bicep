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

@description('The administrator password of the SQL logical server.')
@secure()
param sqlSvrAdminLogin string

@description('The administrator password of the SQL logical server.')
@secure()
param sqlSvrAdminPassword string 

@description('Azure AD user name for AAD authentication in SQL Logical Server')
param aadAdminLogin string

@description('Azure AD Object Id for AAD authentication in SQL Logical Server')
param aadAdminLoginObjectId string

@allowed([
  'basic'
  'medium'
  'high'
  'intense'
])
@description('Predefined sizing of the SQL database')
param sqlDbSize string

@description('Create ADF Managed Private Endpoint for the App during provisioning')
param createADFPrivateEndpoint bool = false

// Generate an unique value for naming the deployment
@description('String for uniqueness')
param unqiueUtc string = utcNow()

// Generate Azure Service name for different environment
var appName = 'intbatch'
var orgAbbr = 'demo'
var adfName = 'adf-${orgAbbr}-${appName}-${environmentName}'
var storageName = 'st${orgAbbr}${appName}${environmentName}'
var keyVaultName = 'kv-${orgAbbr}-${appName}-${environmentName}'
var sqlSvrName = 'sql-${orgAbbr}-${appName}-${environmentName}'
var sqlDbName = 'sqldb-${orgAbbr}-${appName}-${environmentName}'

// Networking name from shared variable file
var sharedNetVariables = loadJsonContent('./network-variables.json')
var vnetRgName = '${sharedNetVariables.vnetRgName}-${environmentName}'
var vnetName = '${sharedNetVariables.vnetName}-${environmentName}'
var snetAppName = '${sharedNetVariables.snetApp}-${environmentName}'
var snetDataName = '${sharedNetVariables.snetData}-${environmentName}'

// Existing Resources
resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  scope: resourceGroup(vnetRgName)
  name: vnetName
}

resource snetApp 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' existing = {
  parent: vnet
  name: snetAppName
}

resource snetData 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' existing = {
  parent: vnet
  name: snetDataName
}

// Provision Data Factory for Public Batch
module adf '../../bicep-modules/data-factory.bicep' = {
  name: '${adfName}-${unqiueUtc}'
  params:{
    dataFactoryLocation: location
    dataFactoryName: adfName
    dataFactoryRepoConfig: repoConfiguration
    publicNetworkAccess: false
    enableManagedVNet: true
  }
}

// Provision Storage Account for ADF Batch
module storageAcct '../../bicep-modules/storage-account.bicep' = {
  name: '${storageName}-${unqiueUtc}'
  params:{
    storageLocation: location
    storageName: storageName
    storageSku: storageSku
    publicNetworkAccess: false
    blobContainers: [
      'raw'
      'cruated'
    ]
  }
}

// Provision Private Endpoint to Func App Storage Account
module peStorageAcct '../../bicep-modules/private-endpoint.bicep' = {
  name: 'pe-${storageName}-${unqiueUtc}'
  params: {
    peLocation: location
    resourceNameforPe: storageName
    resourceIdforPe: storageAcct.outputs.id
    vnetId: vnet.id
    subnetId: snetApp.id
    peGroupId: 'blob'
  }
  dependsOn:[
    storageAcct 
  ]
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

// Provision Key Vault for the product
module keyVault '../../bicep-modules/key-vault.bicep' = {
  name: '${keyVaultName}-${unqiueUtc}'
  params: {
    keyVaultName: keyVaultName
    keyVaultLocation: location
    publicNetworkAccess: false
  }
}

// Provision Private Endpoint to Func App Storage Account
module peKeyVault '../../bicep-modules/private-endpoint.bicep' = {
  name: 'pe-${keyVaultName}-${unqiueUtc}'
  params: {
    peLocation: location
    resourceNameforPe: keyVaultName
    resourceIdforPe: keyVault.outputs.id
    vnetId: vnet.id
    subnetId: snetApp.id
    peGroupId: 'vault'
  }
  dependsOn:[
    keyVault 
  ]
}

// Grant access on Key Vault to ADF Managed Identity
module kvGrantAccess '../../bicep-modules/key-vault-secert-access.bicep' = {
  name: '${keyVaultName}-access-${unqiueUtc}'
  params:{
    keyVaultName: keyVaultName
    managedIdentityIds: [ 
      adf.outputs.managedIdentityId 
    ]
  }
  dependsOn:[
    peKeyVault // ensure sequence operation
  ]
}

// Create placeholder for SQL Connection String
// For demostration purpose, Managed Identity is recommended
resource secretSqlLoginName 'Microsoft.KeyVault/vaults/secrets@2022-07-01' =  {
  name: '${keyVaultName}/SqlConnString'
  properties:{
    contentType: 'string'
    value: 'Server=tcp:${sqlSvrName}${environment().suffixes.sqlServerHostname};Database=${sqlDbName};User ID=${sqlSvrAdminLogin};Password=${sqlSvrAdminPassword};'
  }
  dependsOn: [
    kvGrantAccess // ensure sequence operation
  ]
}

// Provision SQL Server for internal applications
module sqlSvr '../../bicep-modules/sql-server.bicep' = {
  name: '${sqlSvrName}-${unqiueUtc}'
  params:{
    sqlSvrLocation: location
    sqlSvrName: sqlSvrName
    sqlSvrAdminLogin: sqlSvrAdminLogin
    sqlSvrAdminPassword: sqlSvrAdminPassword
    aadAdminLogin: aadAdminLogin
    aadAdminObjectId: aadAdminLoginObjectId
    publicNetworkAccess: false
  }
}

// Provision SQL database for Office Hours API
module sqlDb '../../bicep-modules/sql-database.bicep' = {
  name: '${sqlDbName}-${unqiueUtc}'
  params:{
    sqlDbLocation: location
    sqlDbName: sqlDbName
    sqlDbSize: sqlDbSize
    sqlSvrName: sqlSvrName
  }
  dependsOn:[
    sqlSvr
  ]
}

// Provision Private Endpoint to SQL
module peSqlSvr '../../bicep-modules/private-endpoint.bicep' = {
  name: 'pe-${sqlSvrName}-${unqiueUtc}'
  params: {
    peLocation: location
    resourceNameforPe: sqlSvrName
    resourceIdforPe: sqlSvr.outputs.id
    vnetId: vnet.id
    subnetId: snetData.id
    peGroupId: 'sqlServer'
  }
  dependsOn:[
    sqlSvr 
  ]
}

// Provision Managed Private Endpoint to Storage Account
module peAdfMgdStorageAcct '../../bicep-modules/data-factory-managed-pep.bicep' = if (createADFPrivateEndpoint) {
  name: 'mpep-${storageName}-${unqiueUtc}'
  params: {
    dataFactoryName: adfName
    resourceIdforPe: storageAcct.outputs.id
    peGroupId: 'blob'
    peName: 'pepBlob${appName}'
  }
  dependsOn:[
    peStorageAcct // wait until the default private endpoint is created 
    adf
  ]
}

// Provision Managed Private Endpoint to Key Vault
module peAdfMgdKeyVault '../../bicep-modules/data-factory-managed-pep.bicep' = if (createADFPrivateEndpoint)  {
  name: 'mpep-${keyVaultName}-${unqiueUtc}'
  params: {
    dataFactoryName: adfName
    resourceIdforPe: keyVault.outputs.id
    peGroupId: 'vault'
    peName: 'pepKv${appName}'
  }
  dependsOn:[
    peKeyVault // wait until the default private endpoint is created 
    adf
  ]
}

// Provision Managed Private Endpoint to Sql server
module peAdfMgdSql '../../bicep-modules/data-factory-managed-pep.bicep' = if (createADFPrivateEndpoint)  {
  name: 'mpep-${sqlSvrName}-${unqiueUtc}'
  params: {
    dataFactoryName: adfName
    resourceIdforPe: sqlSvr.outputs.id
    peGroupId: 'sqlServer'
    peName: 'pepSql${appName}'
  }
  dependsOn:[
    peSqlSvr // wait until the default private endpoint is created 
    adf
  ]
}

output blobMgdPepName string = peAdfMgdStorageAcct.outputs.privateEndpointName
output keyvaultMgdPepName string = peAdfMgdKeyVault.outputs.privateEndpointName
output sqlMgdPepName string = peAdfMgdSql.outputs.privateEndpointName
output defaultIrId string = adf.outputs.defaultIrId
output adfName string = adfName
