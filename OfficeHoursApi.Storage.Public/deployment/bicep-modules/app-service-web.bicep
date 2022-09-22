// Bicep module to provision a Web App in Linux App Service Plan
// -------------------------------------------------------------
@description('Location for Web App')
param webAppLocation string

@description('Name of Web App')
param webAppName string

@description('Name of App Service Plan for Web App')
param planName string

@allowed([
  'dotnet'
  'python'
  'node'
  'java'
])
@description('Language Runtime for the Web App')
param langEngine string

@description('Optional app settings for the Web App')
param appSettings array = []

resource webAppServicePlan 'Microsoft.Web/serverfarms@2022-03-01' existing = {
  name: planName
}

var fxConfigure = {
  dotnet: {
    fxVersion: 'DOTNETCORE|6'
  }
  python: {
    fxVersion: 'PYTHON|3.9'
  }
  node: {
    fxVersion: 'NODE|16-lts'
  }
  java: {
    fxVersion: 'JAVA|11-java11'
  }
}

resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: webAppName
  location: webAppLocation
  identity:{
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: webAppServicePlan.id
    siteConfig: {
      linuxFxVersion: fxConfigure[langEngine].fxVersion
      appSettings: appSettings
    }
    httpsOnly: true
  }
}

output id string = webApp.id
output managedIdentityId string = webApp.identity.principalId
output outboundIps string = webApp.properties.possibleOutboundIpAddresses
