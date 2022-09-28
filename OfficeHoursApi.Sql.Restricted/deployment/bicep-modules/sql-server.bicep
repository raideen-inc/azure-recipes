// Bicep module to provision a SQL Logical Server
// ----------------------------------------------
@description('Location for the SQL logical server')
param sqlSvrLocation string

@description('Name of the SQL logical server')
param sqlSvrName string

@description('The administrator username of the SQL logical server.')
param sqlSvrAdminLogin string

@description('The administrator password of the SQL logical server.')
@secure()
param sqlSvrAdminPassword string

@description('The Azure AD administrator of the SQL logical server.')
param aadAdminLogin string

@description('The Azure AD administrator of the SQL logical server.')
param aadAdminObjectId string

resource sqlServer 'Microsoft.Sql/servers@2022-02-01-preview' = {
  name: sqlSvrName
  location: sqlSvrLocation
  properties: {
    administratorLogin: sqlSvrAdminLogin
    administratorLoginPassword: sqlSvrAdminPassword
    publicNetworkAccess: 'Enabled'
  }
}

// Enable Azure AD administration, required for managed identity
resource sqlServerAAD 'Microsoft.Sql/servers/administrators@2022-02-01-preview' = {
  name: 'ActiveDirectory'
  parent: sqlServer
  properties: {
    administratorType: 'ActiveDirectory'
    login: aadAdminLogin
    sid: aadAdminObjectId
    tenantId: tenant().tenantId
  }
}

output sqlSvrUrl string = sqlServer.properties.fullyQualifiedDomainName
