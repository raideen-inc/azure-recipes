// Bicep module to provision a Service Plan for Azure Functions
// ------------------------------------------------------------
@description('Location for the App Service Plan')
param planLocation string

@description('Name of the App Service Plan')
param planName string

// Found out a list of SKU: https://azure.microsoft.com/en-us/pricing/details/app-service/linux/ 
// In addition, Azure Functions specific SKU are: 
// - Consumption Plan = Y1
// - Premimum Plan = EP1, EP2, EP3
@allowed([
  'Y1'
  'B1'
  'S1'
  'EP1'
])
@description('Pricing/Sizing tier of the App Service Plan')
param planSku string

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: planName
  location: planLocation
  kind: 'linux'
  sku: {
    name: planSku
  }
  properties: {
    // for Linux plan, you must set reserved to true
    reserved: true
  }
}

output id string = appServicePlan.id
