// Bicep module to add Role assignment
// - https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/scenarios-rbac
// -------------------------------------------------------------------------------------
@description('Name of the storage account to be accessed')
param storageAcctName string

@description('Principal Id to be granted access')
param principalId string

@allowed([
  'TableDataContributor'
  'TableDataReader'
  'BlobDataContributor'
  'BlobDataReader'
  'BlobDataOwner'
])
@description('Predefined role to be assigned')
param roleName string

// Found out the role guid at: https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
var roleGuidLookup = {
  TableDataContributor: {
    roleDefinitionId: '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3'
  }
  TableDataReader: {
    roleDefinitionId: '76199698-9eea-4c19-bc75-cec21354c6b6'
  }
  BlobDataContributor: {
    roleDefinitionId: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
  }
  BlobDataReader: {
    roleDefinitionId: '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
  }
  BlobDataOwner: {
    roleDefinitionId: 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'
  }
}

resource storageAcct 'Microsoft.Storage/storageAccounts@2022-05-01' existing ={
  name: storageAcctName
}

resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: roleGuidLookup[roleName].roleDefinitionId
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: storageAcct
  name: guid(resourceGroup().id, principalId, roleName)
  properties: {
    roleDefinitionId: roleDefinition.id
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

