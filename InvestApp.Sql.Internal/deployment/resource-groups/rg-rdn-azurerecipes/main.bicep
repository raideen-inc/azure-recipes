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
  'B1'
  'S1'
  'P1V3'
])
@description('Pricing/Sizing tier of the App Service Plan')
param planSku string

@allowed([
  'Free'
  'PerGB2018'
  'PerNode'
])
@description('Pricing tier of Log Analytic Workspace')
param logAnalyticSku string

@allowed([
  'Standard_LRS'
  'Standard_ZRS'
])
@description('Pricing/Sizing tier of the Function App Storage Account')
param funcStorageSku string

@description('The administrator password of the SQL logical server.')
@secure()
param sqlSvrAdminLogin string

@description('The administrator password of the SQL logical server.')
@secure()
param sqlSvrAdminPassword string 

@description('Azure AD user name for AAD authentication in SQL Logical Server')
param aadAdminLogin string

@description('Predefined sizing of the SQL database')
param aadAdminLoginObjectId string

@allowed([
  'basic'
  'medium'
  'high'
  'intense'
])
@description('Predefined sizing of the SQL database')
param sqlDbSize string

// Generate an unique value for naming the deployment
@description('String for uniqueness')
param unqiueUtc string = utcNow()

// Generate Azure Service name for different environment
var appName = 'invest'
var orgAbbr = 'demo'
var appInsightsName = 'appi-${orgAbbr}-${appName}-${environmentName}'
var logAnalyticName = 'log-${orgAbbr}-${appName}-${environmentName}'
var planName = 'plan-${orgAbbr}-${appName}-${environmentName}'
var webAppName = 'app-${orgAbbr}-${appName}-${environmentName}'
var funcAppName = 'func-${orgAbbr}-${appName}-${environmentName}'
var funcStorageName = 'stfu${orgAbbr}${appName}${environmentName}'
var sqlSvrName = 'sql-${orgAbbr}-${appName}-${environmentName}'
var sqlDbName = 'sqldb-${orgAbbr}-${appName}-${environmentName}'
var keyVaultName = 'kv-${orgAbbr}-${appName}-${environmentName}'

// Secret Name
var appInsightsConnStrSecretName = 'AppInsightsConnectionString'
var sqlConnStrSecretName = 'Sql-${sqlDbName}'

// Networking name from shared variable file
var sharedNetVariables = loadJsonContent('./network-variables.json')
var vnetRgName = '${sharedNetVariables.vnetRgName}-${environmentName}'
var vnetName = '${sharedNetVariables.vnetName}-${environmentName}'
var snetAppName = '${sharedNetVariables.snetApp}-${environmentName}'
var snetAppIntName = '${sharedNetVariables.snetAppInt}-${environmentName}'
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

resource snetAppInt 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' existing = {
  parent: vnet
  name: snetAppIntName
}

resource snetData 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' existing = {
  parent: vnet
  name: snetDataName
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

// Provision Private Endpoint to Key Vault
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
}

// Provision App Insights for the product
module appInsights '../../bicep-modules/app-insights.bicep' = {
  name: '${appInsightsName}-${unqiueUtc}'
  params: {
    appInsightsLocation: location
    appInsightsName: appInsightsName
    logAnalyticsName: logAnalyticName
    logAnalyticSku: logAnalyticSku
  }
}

// Provision App Service Plan for web app & func app
module planForInternalApp '../../bicep-modules/app-service-plan-linux.bicep'= {
  name: '${planName}-${unqiueUtc}'
  params:{
    planLocation: location
    planName: planName
    planSku: planSku
  }
}

// FYI: environment() => https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-functions-deployment#environment
// Provision Web App for internal application
module webApp '../../bicep-modules/app-service-web.bicep' = {
  name: '${webAppName}-${unqiueUtc}'
  params:{
    webAppLocation: location
    webAppName: webAppName
    planName: planName
    langEngine: 'dotnet'
    appSettings: [
      {
        name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
        value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=${appInsightsConnStrSecretName})'
      }
      {
        name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
        value: '~3' // use ~3 for Linux, ~2 for Windows
      }
      {
        name: 'XDT_MicrosoftApplicationInsights_Mode'
        value: 'recommended' // used for .NET Core, ignored for other runtimes
      }
      {
        name: 'AZURE_SQL_CONNECTIONSTRING'
        value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=${sqlConnStrSecretName})'
      }
    ]
    subnetIdforIntegration: snetAppInt.id
    publicNetworkAccess: false
  }
  dependsOn:[
    planForInternalApp
  ]
}

// Provision Private Endpoint to Web App
module peWebApp '../../bicep-modules/private-endpoint.bicep' = {
  name: 'pe-${webAppName}-${unqiueUtc}'
  params: {
    peLocation: location
    resourceNameforPe: webAppName
    resourceIdforPe: webApp.outputs.id
    vnetId: vnet.id
    subnetId: snetApp.id
    peGroupId: 'sites'
  }
  dependsOn:[
    webApp 
  ]
}

// Provision Storage Account for Functions App
module funcStorageAcct '../../bicep-modules/storage-account.bicep' = {
  name: '${funcStorageName}-${unqiueUtc}'
  params:{
    storageLocation: location
    storageName: funcStorageName
    storageSku: funcStorageSku
    publicNetworkAccess: false
  }
}

// Provision Private Endpoint to Func App Storage Account
module peFuncStorage '../../bicep-modules/private-endpoint.bicep' = {
  name: 'pe-${funcStorageName}-${unqiueUtc}'
  params: {
    peLocation: location
    resourceNameforPe: funcStorageName
    resourceIdforPe: funcStorageAcct.outputs.id
    vnetId: vnet.id
    subnetId: snetApp.id
    peGroupId: 'blob'
  }
  dependsOn:[
    funcStorageAcct 
  ]
}

// Provision Function App for Batch Update
module funcApp '../../bicep-modules/funcapp-linux.bicep'= {
  name: '${funcAppName}-${unqiueUtc}'
  params:{
    funcAppLocation: location
    funcAppName: funcAppName
    funcPlanName: planName
    funcAppInsightsName: appInsightsName
    runtime: 'dotnet'
    funcStorageName: funcStorageName
    keyVaultName: keyVaultName
    subnetIdforIntegration: snetAppInt.id
    additionalAppSetting: [
      {
        name: 'AZURE_SQL_CONNECTIONSTRING'
        value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=${sqlConnStrSecretName})'
      }
      {
        name: 'CRON_BATCH_UPDATE'
        value: '0 0 21 * * *'
      }
    ]
    publicNetworkAccess: false
    appInsightsConnStrSecretName: appInsightsConnStrSecretName
  }
  dependsOn: [
    planForInternalApp
    funcStorageAcct
    appInsights
    keyVault
  ]
}

// Provision Private Endpoint to Func App
module peFuncApp '../../bicep-modules/private-endpoint.bicep' = {
  name: 'pe-${funcAppName}-${unqiueUtc}'
  params: {
    peLocation: location
    resourceNameforPe: funcAppName
    resourceIdforPe: funcApp.outputs.id
    vnetId: vnet.id
    subnetId: snetApp.id
    peGroupId: 'sites'
  }
  dependsOn:[
    funcApp
    peWebApp // wait for privatelink.azurewebsites.net to complete
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

// Add secrets to Key Vault
module kvAddSecrets '../../bicep-modules/app-service-add-secrets.bicep' = {
  name: '${keyVaultName}-secrets-${unqiueUtc}'
  params:{
    keyVaultName: keyVaultName
    sqlDbName: sqlDbName
    sqlSvrName: sqlSvrName
    sqlConnStrSecretName: sqlConnStrSecretName
    appInsightsName: appInsightsName
    appInsightsConnStrSecretName: appInsightsConnStrSecretName
  }
  dependsOn:[
    keyVault
    peKeyVault
    appInsights
    webApp
  ]
}

// Grant access for Managed Identity for Web App to Key Vault
module kvGrantAccess '../../bicep-modules/key-vault-secert-access.bicep' = {
  name: '${keyVaultName}-access-${unqiueUtc}'
  params:{
    keyVaultName: keyVaultName
    managedIdentityIds: [ 
      webApp.outputs.managedIdentityId 
      //funcApp.outputs.managedIdentityId - not required, part of the funcapp-linux module
    ]
  }
  dependsOn:[
    kvAddSecrets // ensure sequence operation
  ]
}

output sqlSvrName string = sqlSvrName
output sqlSvrFqdn string = sqlSvr.outputs.sqlSvrUrl
output sqlDbName string = sqlDbName
output webAppName string = webAppName
output funcAppName string = funcAppName

