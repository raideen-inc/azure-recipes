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
  'F1'
  'B1'
  'S1'
  'P1V3'
])
@description('Pricing/Sizing tier of the App Service Plan')
param planSku string

@description('Ip address allowed to access API site')
param ipAddressesAllowed array

@description('Ip address allowed to access SCM site')
param ipAddressesScmAllowed array

@description('The administrator password of the SQL logical server.')
@secure()
param sqlSvrAdminLogin string

@description('The administrator password of the SQL logical server.')
@secure()
param sqlSvrAdminPassword string 

@description('Azure AD user name for AAD authentication in SQL Logical Server')
param aadAdminLogin string

@description('Azure AD object Id for AAD authentication in SQL Logical Server')
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
var appName = 'officehoursapi'
var orgAbbr = 'demo'
var planName = 'plan-${orgAbbr}-${appName}-${environmentName}'
var webAppName = 'app-${orgAbbr}-${appName}-${environmentName}'
var sqlSvrName = 'sql-${orgAbbr}-${appName}-${environmentName}'
var sqlDbName = 'sqldb-${orgAbbr}-${appName}-${environmentName}'

// Provision App Service Plan for public facing applications
module planForWebApp '../../bicep-modules/app-service-plan-linux.bicep'= {
  name: '${planName}-${unqiueUtc}'
  params:{
    planLocation: location
    planName: planName
    planSku: planSku
  }
}

// FYI: environment() => https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-functions-deployment#environment
// Provision Web App for Office Hours API
module webApp '../../bicep-modules/app-service-web.bicep' = {
  name: '${webAppName}-${unqiueUtc}'
  params:{
    webAppLocation: location
    webAppName: webAppName
    planName: planName
    langEngine: 'dotnet'
    appSettings: [
      {
        name: 'AZURE_SQL_CONNECTIONSTRING'
        value: 'Server=tcp:${sqlSvrName}${environment().suffixes.sqlServerHostname};Authentication=Active Directory Default; Database=${sqlDbName};'
      }
    ]
  }
  dependsOn:[
    planForWebApp
  ]
}

// Add firewall rules in Web App to allow access from given IP addresses
module webAppRestriction '../../bicep-modules/app-service-firewall.bicep' = {
  name: 'webAppRe-${unqiueUtc}'
  params: {
    webAppName: webAppName
    ruleName: 'Allow-Ip'
    allowedIpList: ipAddressesAllowed
    allowedIpListScm: ipAddressesScmAllowed
  }
  dependsOn:[
    webApp
  ]
}

// get secert directly: https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/key-vault-parameter?tabs=azure-cli
// Provision SQL Server for public facing applications
module sqlSvr '../../bicep-modules/sql-server.bicep' = {
  name: '${sqlSvrName}-${unqiueUtc}'
  params:{
    sqlSvrLocation: location
    sqlSvrName: sqlSvrName
    sqlSvrAdminLogin: sqlSvrAdminLogin
    sqlSvrAdminPassword: sqlSvrAdminPassword
    aadAdminLogin: aadAdminLogin
    aadAdminObjectId: aadAdminLoginObjectId
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

// Add firewall rules in SQL to allow access from Web App
var sqlFwRuleName = 'App-Service-Inbound'
module sqlSvrFirewallRule '../../bicep-modules/sql-server-firewall.bicep' = {
  name: '${sqlFwRuleName}-${unqiueUtc}'
  params:{
    sqlSvrName: sqlSvrName
    ruleName: sqlFwRuleName
    ipAddresses: split(webApp.outputs.outboundIps, ',')
  }
  dependsOn:[
    webApp
    sqlSvr
  ]
}

output sqlSvrName string = sqlSvrName
output sqlSvrFqdn string = sqlSvr.outputs.sqlSvrUrl
output sqlDbName string = sqlDbName
output webAppName string = webAppName
