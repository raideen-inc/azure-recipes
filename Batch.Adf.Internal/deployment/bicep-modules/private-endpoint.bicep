// Bicep module to provision private endpoint for a Key Vault
// -----------------------------------------------------------
@description('Location for the Private Endpoint')
param peLocation string

@description('Name of the target resource')
param resourceNameforPe string

@description('Object Id of the target resource')
param resourceIdforPe string

@description('Id of VNET, where the private endpoint reside')
param vnetId string

@description('Id of Subnet, where the private endpoint reside')
param subnetId string

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

// Generate names
var peName = 'pe-${resourceNameforPe}'
var peNicName = 'nic-${peName}'
var plName = 'pl-${resourceNameforPe}'

var privateDnsZoneLinkName = '${privateDnsZoneName}-link'
var privateDnsZoneGroupName = '${privateDnsZoneName}-group'

// Provision Private Endpoint
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: peName
  location: peLocation
  properties: {
    subnet: {
      id: subnetId
    }
    customNetworkInterfaceName: peNicName
    privateLinkServiceConnections: [
      {
        name: plName
        properties: {
          privateLinkServiceId: resourceIdforPe
          groupIds: [
            peGroupId
          ]
        }
      }
    ]
  }
}

// Provision Private DNS Zones for the private endpoint
resource privateDnsZones 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZones
  name: privateDnsZoneLinkName
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-03-01' = {
  parent: privateEndpoint
  name: privateDnsZoneGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'configure-1'
        properties: {
          privateDnsZoneId: privateDnsZones.id
        }
      }
    ]
  }
}
