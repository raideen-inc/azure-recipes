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

@allowed([
  'Standard_LRS'
  'Standard_ZRS'
  'Standard_GZRS'
])
@description('Pricing/Sizing tier of the Storage Account')
param storageSku string

// Generate an unique value for naming the deployment
@description('String for uniqueness')
param unqiueUtc string = utcNow()

// Generate Azure Service name for different environment
var appName = '<your-app-name>'
var orgAbbr = '<your-org-abbreviations>'
var planName = 'plan-${orgAbbr}-${appName}-${environmentName}'
var webAppName = 'app-${orgAbbr}-${appName}-${environmentName}'
var storageAcctName = 'st${orgAbbr}${appName}${environmentName}'

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
        name: 'STORAGE_TABLE_CONNSTRING'
        value:  'https://${storageAcctName}.table.${environment().suffixes.storage}/'
      }
    ]
  }
  dependsOn:[
    planForWebApp
  ]
}

// Provision Storage Account for Office Hours API
module storageAcct '../../bicep-modules/storage-account.bicep' = {
  name: '${storageAcctName}-${unqiueUtc}'
  params:{
    storageLocation: location
    storageName: storageAcctName
    storageSku: storageSku
  }
}

// Grant table data contributor role to the Web App managed identity
module roleAssignStorage '../../bicep-modules/storage-account-role-assign.bicep' = {
  name: '${storageAcctName}role-${unqiueUtc}'
  params: {
    storageAcctName: storageAcctName
    principalId: webApp.outputs.managedIdentityId
    roleName: 'TableDataContributor'
  }
  dependsOn: [
    webApp
    storageAcct
  ]
}

output webAppName string = webAppName
