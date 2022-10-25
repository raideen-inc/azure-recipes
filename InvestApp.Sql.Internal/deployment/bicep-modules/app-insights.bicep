// Bicep module to provision an Applicatoin Insights
// -------------------------------------------------
@description('Location for Application Insights')
param appInsightsLocation string

@description('Name of Application Insights')
param appInsightsName string

@description('Name of Log Analytic Workspace for Application Insights')
param logAnalyticsName string

// You should check if your organization have a standardized approach for Azure Monitor,
// Some of the Sku may not apply to you
@allowed([
  'Free'
  'PerGB2018'
  'PerNode'
  'Standard'
])
@description('Pricing tier of Log Analytic Workspace')
param logAnalyticSku string = 'Standard'

// Create a Log Analystic Workspace for App Insights
// Note that if you want to reuse an existing workspace, you need to use 'existing'
resource logAnalytic 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: logAnalyticsName
  location: appInsightsLocation
  properties: {
    sku: {
      name: logAnalyticSku
    }
  }
}

// Create an Application Insights instance
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: appInsightsLocation
  kind: 'web'
  properties: { 
    Application_Type: 'web'
    
    // configurable properties:
    DisableLocalAuth: false
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    WorkspaceResourceId: logAnalytic.id
  }
}
