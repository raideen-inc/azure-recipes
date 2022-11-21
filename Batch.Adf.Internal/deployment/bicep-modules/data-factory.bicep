// Bicep module to provision a Data Factory

@description('Location for the Data Factory')
param dataFactoryLocation string

@description('Name of the Data Factory')
param dataFactoryName string

@description('Configuration for Source Code repo')
param dataFactoryRepoConfig object

@description('Indicate if Self-Hosted IR access path is public or private')
param publicNetworkAccess bool = true

@description('Indicate if Managed Virtual Network should be enabled or not')
param enableManagedVNet bool = false

var managedVNetName = 'default' // name must be 'default'
var defaultIrName = 'AutoResolveIntegrationRuntime'

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

resource managedVirtualNetwork 'Microsoft.DataFactory/factories/managedVirtualNetworks@2018-06-01' = if (enableManagedVNet) {
  name: managedVNetName
  parent: dataFactory
  properties: {}
}

resource managedIntegrationRuntime 'Microsoft.DataFactory/factories/integrationRuntimes@2018-06-01' = if (enableManagedVNet) {
  name: defaultIrName
  parent: dataFactory
  properties: {
    type: 'Managed'
    managedVirtualNetwork: {
      referenceName: managedVNetName
      type: 'ManagedVirtualNetworkReference'
    }
    typeProperties: {
      computeProperties: {
        location: 'AutoResolve'
        dataFlowProperties: {
          computeType: 'General'
          coreCount: 4
          timeToLive: 0
        }
      }
    }
  }
  dependsOn: [
    managedVirtualNetwork
  ]
}

output defaultIrId string = managedIntegrationRuntime.id
output managedIdentityId string = dataFactory.identity.principalId
