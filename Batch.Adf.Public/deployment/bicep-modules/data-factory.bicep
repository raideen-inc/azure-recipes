// Bicep module to provision a Data Factory

@description('Location for the Data Factory')
param dataFactoryLocation string

@description('Name of the Data Factory')
param dataFactoryName string

@description('Configuration for Source Code repo')
param dataFactoryRepoConfig object

@description('Indicate if Storage Account has public access or not')
param publicNetworkAccess bool = true

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: dataFactoryName
  location: dataFactoryLocation
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    repoConfiguration: dataFactoryRepoConfig
    publicNetworkAccess: publicNetworkAccess ? 'Enabled' : 'Disabled'
  }
}

output managedIdentityId string = dataFactory.identity.principalId
