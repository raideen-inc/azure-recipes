// Bicep module to provision a Data Factory Managed Private Endpoint

@description('Name of the Data Factory')
param dataFactoryName string

@description('Object Id of the target resource')
param resourceIdforPe string

@allowed([
  'vault'
  'sites'
  'sqlServer'
  'blob'
  'file'
  'queue'
  'table'
  'dfs'
  'web'
])
@description('Group Id for the private endpoint')
param peGroupId string

@description('Name for the Managed Privated Endpoint in ADF')
param peName string

// Zone name lookup
var zoneNameLookup = {
  vault: {
    zone: 'privatelink.vaultcore.azure.net'
  }
  sites: {
    zone: 'privatelink.azurewebsites.net'
  }
  sqlServer: {
    zone: 'privatelink${environment().suffixes.sqlServerHostname}'
  }
  blob: {
    zone: 'privatelink.blob.${environment().suffixes.storage}'
  }
  file: {
    zone: 'privatelink.file.${environment().suffixes.storage}'
  }
  queue: {
    zone: 'privatelink.queue.${environment().suffixes.storage}'
  }
  table: {
    zone: 'privatelink.table.${environment().suffixes.storage}'
  }
  dfs: {
    zone: 'privatelink.dfs.${environment().suffixes.storage}'
  }
  web: {
    zone: 'privatelink.web.${environment().suffixes.storage}'
  }
}
var privateDnsZoneName = zoneNameLookup[peGroupId].zone
var managedVNetName = 'default' // name must be 'default'

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: dataFactoryName
}

resource managedVirtualNetwork 'Microsoft.DataFactory/factories/managedVirtualNetworks@2018-06-01' existing = {
  name: managedVNetName
  parent: dataFactory
}

resource peResource 'Microsoft.DataFactory/factories/managedVirtualNetworks/managedPrivateEndpoints@2018-06-01' = {
  name: peName
  parent: managedVirtualNetwork
  properties: {
    connectionState: {}
    fqdns: [
      privateDnsZoneName
    ]
    groupId: peGroupId
    privateLinkResourceId: resourceIdforPe
  }
}

output privateEndpointName string = peName
