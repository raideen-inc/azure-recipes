// Bicep module to add Role assignment
// - https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/scenarios-rbac
// -------------------------------------------------------------------------------------
@description('Name of the application insights to be accessed')
param appInsightsName string

@description('Principal Id to be granted access')
param principalId string

@allowed([
  'MonitoringMetricsPublisher'
])
@description('Predefined role to be assigned')
param roleName string = 'MonitoringMetricsPublisher'

// Found out the role guid at: https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
var roleGuidLookup = {
  MonitoringMetricsPublisher: {
    roleDefinitionId: '3913510d-42f4-4e42-8a64-420c390055eb'
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing ={
  name: appInsightsName
}

resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: roleGuidLookup[roleName].roleDefinitionId
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: appInsights
  name: guid(resourceGroup().id, principalId, roleName)
  properties: {
    roleDefinitionId: roleDefinition.id
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

