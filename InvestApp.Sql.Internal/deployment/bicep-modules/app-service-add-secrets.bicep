// Bicep module to add secerts for Web App to Key Vault
// Note that this module is specifically for this deployment scenario
// ------------------------------------------------------------------
@description('Name of Function App')
param keyVaultName string

@description('Name of Application Insights')
param appInsightsName string

@description('Name of the logical SQL server')
param sqlSvrName string

@description('Name of the SQL database')
param sqlDbName string

@description('Secret name for the Application Insights connection string')
param appInsightsConnStrSecretName string

@description('Secret name for the SQL Database connection string')
param sqlConnStrSecretName string

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsName
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName

  resource secretAppInsights 'secrets@2022-07-01' =  {
    name: appInsightsConnStrSecretName
    properties:{
      contentType: 'string'
      value: appInsights.properties.ConnectionString
    }
  }

  resource secretSql 'secrets@2022-07-01' =  {
    name: sqlConnStrSecretName
    properties:{
      contentType: 'string'
      value: 'Server=tcp:${sqlSvrName}${environment().suffixes.sqlServerHostname};Authentication=Active Directory Default; Database=${sqlDbName};'
    }
  }
}





