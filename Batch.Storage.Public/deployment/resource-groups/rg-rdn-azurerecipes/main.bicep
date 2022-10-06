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
  'Y1'
  'B1'
  'S1'
  'EP1'
])
@description('Pricing/Sizing tier of the Functions App Service Plan')
param planSku string

@allowed([
  'Free'
  'PerGB2018'
  'PerNode'
  'Standard'
])
@description('Pricing tier of Log Analytic Workspace')
param logAnalyticSku string = 'Standard'

@allowed([
  'Standard_LRS'
  'Standard_ZRS'
  'Standard_GZRS'
])
@description('Pricing/Sizing tier of the data Storage Account')
param storageSku string

@allowed([
  'Standard_LRS'
  'Standard_ZRS'
])
@description('Pricing/Sizing tier of the Function App Storage Account')
param funcStorageSku string

@description('Ip address allowed to access API site')
param ipAddressesAllowed array

@description('Ip address allowed to access SCM site')
param ipAddressesScmAllowed array

// Generate an unique value for naming the deployment
@description('String for uniqueness')
param unqiueUtc string = utcNow()

// Generate Azure Service name for different environment
var appName = 'pubibatch'
var orgAbbr = 'demo'
var appInsightsName = 'appi-${orgAbbr}-${appName}-${environmentName}'
var logAnalyticName = 'log-${orgAbbr}-${appName}-${environmentName}'
var planName = 'plan-${orgAbbr}-${appName}-${environmentName}'
var funcAppName = 'func-${orgAbbr}-${appName}-${environmentName}'
var funcStorageName = 'stfu${orgAbbr}${appName}${environmentName}'
var dataStorageName = 'st${orgAbbr}${appName}${environmentName}'
var keyVaultName = 'kv-${orgAbbr}-${appName}-${environmentName}'

module keyVault '../../bicep-modules/keyvault.bicep' = {
  name: '${keyVaultName}-${unqiueUtc}'
  params: {
    keyVaultName: keyVaultName
    keyVaultLocation: location
  }
}

// Provision Storage Account for Data Storage
module dataStorageAcct '../../bicep-modules/storage-account.bicep' = {
  name: '${dataStorageName}-${unqiueUtc}'
  params:{
    storageLocation: location
    storageName: dataStorageName
    storageSku: storageSku
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

// Provision Storage Account for Functions App
module funcStorageAcct '../../bicep-modules/storage-account.bicep' = {
  name: '${funcStorageName}-${unqiueUtc}'
  params:{
    storageLocation: location
    storageName: funcStorageName
    storageSku: funcStorageSku
  }
}

// Provision App Service Plan for Fucntion App
module funcAppPlan '../../bicep-modules/funcapp-plan-linux.bicep'= {
  name: '${planName}-${unqiueUtc}'
  params:{
    planLocation: location
    planName: planName
    planSku: planSku
  }
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
    additionalAppSetting: [
      {
        name: 'TARGET_STORAGE__serviceUri'
        value: 'https://${dataStorageName}.blob.${environment().suffixes.storage}/'
      }
      {
        name: 'SOURCE_API_URL'
        value: 'https://api.open-meteo.com/v1/forecast?latitude=40.71&longitude=-74.01&hourly=temperature_2m'
      }
      {
        name: 'TARGET_FILE_NAME'
        value: 'output/forecast-{DateTime}.json'
      }
      {
        name: 'CRON_BATCH_UPDATE'
        value: '0 */5 * * * *'
      }
    ]
  }
  dependsOn: [
    funcAppPlan
    funcStorageAcct
    appInsights
    keyVault
  ]
}

// Add firewall rules in Web App to allow access from given IP addresses
module funcAppRestriction '../../bicep-modules/app-service-firewall.bicep' = {
  name: 'funcAppRestrict-${unqiueUtc}'
  params: {
    appName: funcAppName
    ruleName: 'Allow-Ip'
    allowedIpList: ipAddressesAllowed
    allowedIpListScm: ipAddressesScmAllowed
  }
  dependsOn:[
    funcApp
  ]
}

// Grant blob data contributor role to the Func App managed identity
// - because of Blob Binding
// https://docs.microsoft.com/en-us/azure/azure-functions/functions-bindings-storage-blob-output?tabs=in-process%2Cextensionv5&pivots=programming-language-csharp#grant-permission-to-the-identity
module roleAssignStorage '../../bicep-modules/storage-account-role-assign.bicep' = {
  name: '${dataStorageName}role-${unqiueUtc}'
  params: {
    storageAcctName: dataStorageName
    principalId: funcApp.outputs.managedIdentityId
    roleName: 'BlobDataOwner'
  }
  dependsOn: [
    funcApp
    dataStorageAcct
  ]
}
