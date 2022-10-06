// Bicep module to provision a Linux-based Functions App
// -----------------------------------------------------
@description('Location for Function App')
param funcAppLocation string

@description('Name of Function App')
param funcAppName string

@description('Name of App Service Plan for Function App')
param funcPlanName string

@description('Name of Application Insights for Function App')
param funcAppInsightsName string

@allowed([
  'dotnet'
  'python'
  'node'
])
@description('Runtime of Function')
param runtime string

@description('Addition application specific settings')
param additionalAppSetting array = []

@description('Name of Storage Account used by Function App')
param funcStorageName string

@description('Name of Key Vault used to store connection string as secret')
param keyVaultName string

// @description('Secert Name for storage account connection string')
// param storageConnStrSecretName string = 'AzureWebJobsStorage-${funcAppName}'

var storageConnStrSecretName = 'AzureWebJobsStorage-${funcAppName}'
var appInsightsConnStrSecretName = 'AppInsights-${funcAppName}'
var configureValues = {
  dotnet: {
    fxVersion: 'dotnetcore'
    extVersion: '~4'
  }
  python: {
    fxVersion: 'python|3.9'
    extVersion: '~4'
  }
  node: {
    fxVersion: 'node|lts'
    extVersion: '~4'
  }
}

resource funcStorageAcc 'Microsoft.Storage/storageAccounts@2022-05-01' existing = {
  name: funcStorageName
}

resource funcAppInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: funcAppInsightsName
}

resource funcAppServicePlan 'Microsoft.Web/serverfarms@2021-03-01' existing = {
  name: funcPlanName
}
var IsComsumptionPlan = funcAppServicePlan.sku.name == 'Y1' || funcAppServicePlan.sku.name == 'EP1'

// Note that consumption plan cannot use key vault reference
// - Bug: https://github.com/microsoft/azure-pipelines-tasks/issues/16749
// Once bug is fixed, we could simplify connection string setting
var connStringStorage = 'DefaultEndpointsProtocol=https;AccountName=${funcStorageAcc.name};AccountKey=${listKeys(funcStorageAcc.id, '2022-05-01').keys[0].value}'
var connStringKVReference = '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=${storageConnStrSecretName})'
var storageConnString = IsComsumptionPlan ? connStringStorage : connStringKVReference

var appInsightsKVReference = '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=${appInsightsConnStrSecretName})'
var appInsightsConnString = IsComsumptionPlan ? funcAppInsights.properties.ConnectionString : appInsightsKVReference

var baseAppSetting = [
  {
    name: 'AzureWebJobsStorage'
    value: storageConnString
  }
  {
    name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
    value: appInsightsConnString
  }
  {
    name: 'FUNCTIONS_WORKER_RUNTIME'
    value: runtime
  }
  {
    name: 'FUNCTIONS_EXTENSION_VERSION'
    value: configureValues[runtime].extVersion
  }
]

// https://docs.microsoft.com/en-us/azure/azure-functions/functions-create-first-function-bicep
// Provision Linux Functions App
resource functionApp 'Microsoft.Web/sites@2021-03-01' = {
  name: funcAppName
  location: funcAppLocation
  kind: 'functionapp,linux'
  identity:{
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: funcAppServicePlan.id
    siteConfig: {
      linuxFxVersion: IsComsumptionPlan ? '' : configureValues[runtime].fxVersion
      alwaysOn: IsComsumptionPlan ? false : true
      appSettings: union(baseAppSetting, additionalAppSetting)
    }
    httpsOnly: true
  }
  dependsOn:[
    funcAppInsights
    funcAppServicePlan
    funcStorageAcc
  ]
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName

  resource storageSecret 'secrets@2022-07-01' = {
    name: storageConnStrSecretName
    properties:{
      contentType: 'string'
      value: connStringStorage
    }
    dependsOn: [
      funcStorageAcc
    ]
  }

  resource AppInsightsSecret 'secrets@2022-07-01' = {
    name: appInsightsConnStrSecretName
    properties:{
      contentType: 'string'
      value: funcAppInsights.properties.ConnectionString
    }
    dependsOn: [
      funcStorageAcc
    ]
  }

  resource accessPolicy 'accessPolicies@2022-07-01' = {
    name:'add'
    properties:{
      accessPolicies: [
        {
          objectId: functionApp.identity.principalId
          tenantId: subscription().tenantId
          permissions:{
            keys: []
            secrets: [
              'get'
              'list'
            ]
            certificates:[]
          }
        }
      ]
    }
  }
}

output managedIdentityId string = functionApp.identity.principalId
output outboundIps string = functionApp.properties.possibleOutboundIpAddresses

