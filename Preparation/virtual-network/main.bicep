@description('Location for the deployment')
param location string = resourceGroup().location

@allowed([
  'dev'
  'test'
  'prod'
])
@description('Short Name to identify the environment')
param environmentName string

@description('Address space prefixes in CIDR for Virtual Network')
param vnetAddressPrefixes array

@description('Address space prefixes in CIDR for data subnet')
param dataSubnetAddress string

@description('Address space prefixes in CIDR for app subnet')
param appSubnetAddress string

@description('Address space prefixes in CIDR for app service vnet integration subnet')
param appIntSubnetAddress string

@description('Address space prefixes in CIDR for virtual machine subnet')
param vmSubnetAddress string

@description('Address space prefixes in CIDR for VPN gateway')
param gatewaySubnetAddress string

@description('Address space prefixes in CIDR for VPN gateway client')
param gatewayClientAddress string

@description('Base64 string for gateway root certificate')
param base64RootCert string

// Generate Azure Service name for different environment
var netName = 'azurerecipes'
var orgAbbr = 'demo'
var vnetName = 'vnet-${orgAbbr}-${netName}-${environmentName}'
var dataSubnetName = 'snet-data-${environmentName}'
var dataNsgName = 'nsg-${dataSubnetName}'
var appSubnetName = 'snet-app-${environmentName}'
var appNsgName = 'nsg-${appSubnetName}'
var appIntSubnetName = 'snet-appInt-${environmentName}'
var appIntNsgName = 'nsg-${appIntSubnetName}'
var vmSubnetName = 'snet-vm-${environmentName}'
var vmNsgName = 'nsg-${vmSubnetName}'

// Virtual Network Gateway can only be created in subnet with name 'GatewaySubnet'
var gatewaySubnetName = 'GatewaySubnet'
var gatewayPipName = 'pip-${orgAbbr}-gateway-${environmentName}'
var gatewayName = 'vpng-${orgAbbr}-${netName}-${environmentName}'

// Provision NSG for data subnet, which allows only 1433 inbound
resource dataNsg 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: dataNsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowSqlInBound'
        properties: {
          description: 'Allow inbound 1433'
          access: 'Allow'
          protocol: 'Tcp'
          destinationAddressPrefix: 'Sql'
          destinationPortRange: '1433'
          direction: 'Inbound'
          priority: 100
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowSqlALBInBound'
        properties: {
          description: 'Allow inbound 1433'
          access: 'Allow'
          protocol: 'Tcp'
          destinationAddressPrefix: 'Sql'
          destinationPortRange: '1433'
          direction: 'Inbound'
          priority: 110
          sourceAddressPrefix: 'AzureLoadBalancer'
          sourcePortRange: '*'
        }
      }
      {
        name: 'DenyOtherSqlInBound'
        properties: {
          description: 'Deny other inbound'
          access: 'Deny'
          protocol: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '*'
          direction: 'Inbound'
          priority: 500
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
    ]
  }
}

// Provision NSG for app subnet, which allows only 443 inbound ?!
resource appNsg 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: appNsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowHttpsInBound'
        properties: {
          description: 'Allow inbound 443'
          access: 'Allow'
          protocol: 'Tcp'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '443'
          direction: 'Inbound'
          priority: 100
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowHttpsALBInBound'
        properties: {
          description: 'Allow inbound 443'
          access: 'Allow'
          protocol: 'Tcp'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '443'
          direction: 'Inbound'
          priority: 110
          sourceAddressPrefix: 'AzureLoadBalancer'
          sourcePortRange: '*'
        }
      }
      {
        name: 'DenyOtherHttpsInBound'
        properties: {
          description: 'Deny other inbound'
          access: 'Deny'
          protocol: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
          direction: 'Inbound'
          priority: 500
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
        }
      }
    ]
  }
}

// Provision NSG for app service vnet integration subnet
resource appIntNsg 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: appIntNsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowHttpsInBound'
        properties: {
          description: 'Allow inbound 443'
          access: 'Allow'
          protocol: 'Tcp'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '443'
          direction: 'Inbound'
          priority: 100
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowHttpsALBInBound'
        properties: {
          description: 'Allow inbound 443'
          access: 'Allow'
          protocol: 'Tcp'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '443'
          direction: 'Inbound'
          priority: 110
          sourceAddressPrefix: 'AzureLoadBalancer'
          sourcePortRange: '*'
        }
      }
      {
        name: 'DenyOtherRdpInBound'
        properties: {
          description: 'Deny other inbound'
          access: 'Deny'
          protocol: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
          direction: 'Inbound'
          priority: 500
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
        }
      }
    ]
  }
}

// Provision NSG for VM subnet
// - allow 443 & 3389 inbound
resource vmNsg 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: vmNsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowHttpsInBound'
        properties: {
          description: 'Allow inbound 443'
          access: 'Allow'
          protocol: 'Tcp'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '443'
          direction: 'Inbound'
          priority: 100
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowHttpsALBInBound'
        properties: {
          description: 'Allow inbound 443'
          access: 'Allow'
          protocol: 'Tcp'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '443'
          direction: 'Inbound'
          priority: 110
          sourceAddressPrefix: 'AzureLoadBalancer'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowRdpInBound'
        properties: {
          description: 'Allow inbound 3389'
          access: 'Allow'
          protocol: 'Tcp'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '3389'
          direction: 'Inbound'
          priority: 120
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowRdpALBInBound'
        properties: {
          description: 'Allow inbound 3389'
          access: 'Allow'
          protocol: 'Tcp'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '3389'
          direction: 'Inbound'
          priority: 130
          sourceAddressPrefix: 'AzureLoadBalancer'
          sourcePortRange: '*'
        }
      }
    ]
  }
}

// Provision the virtual network for internal web application
resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: vnetAddressPrefixes
    }
    subnets: [
      {
        name: dataSubnetName
        properties: {
          addressPrefix: dataSubnetAddress
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          networkSecurityGroup: json('{"id": "${resourceId('Microsoft.Network/networkSecurityGroups', dataNsgName)}"}') 
        }
      }
      {
        name: appSubnetName
        properties: {
          addressPrefix: appSubnetAddress
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          networkSecurityGroup: json('{"id": "${resourceId('Microsoft.Network/networkSecurityGroups', appNsgName)}"}') 
        }
      }
      {
        name: appIntSubnetName
        properties: {
          addressPrefix: appIntSubnetAddress
          networkSecurityGroup: json('{"id": "${resourceId('Microsoft.Network/networkSecurityGroups', appIntNsgName)}"}') 
          delegations: [
            {
              name: 'delegation'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
      }
      {
        name: vmSubnetName
        properties: {
          addressPrefix: vmSubnetAddress
          networkSecurityGroup: json('{"id": "${resourceId('Microsoft.Network/networkSecurityGroups', vmNsgName)}"}') 
        }
      }
    ]
  }
  dependsOn:[
    dataNsg
    appNsg
    appIntNsg
    vmNsg
  ]
}

// // Provision subnet for VNet Gateway
resource snetGateway 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' = {
  name: gatewaySubnetName
  parent: vnet
  properties: {
    addressPrefix: gatewaySubnetAddress
  }
}

// public ip address for VNet Gateway
resource pipGateway 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: gatewayPipName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

// Provision VNet gateway for P2S VPN
resource gateway 'Microsoft.Network/virtualNetworkGateways@2022-01-01' = {
  name: gatewayName
  location: location
  properties:{
    enablePrivateIpAddress: false
    ipConfigurations: [
      {
        name: 'default'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pipGateway.id
          }
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, gatewaySubnetName)
          }
        }
      }
    ]
    sku: {
      name: 'Basic'
      tier: 'Basic'
    }
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    enableBgp: false
    activeActive: false
    vpnGatewayGeneration: 'Generation1'
    vpnClientConfiguration: {
      vpnClientAddressPool: {
        addressPrefixes: [
          gatewayClientAddress
        ]
      }
      vpnClientRootCertificates: [
        {
          name: 'P2SRootCert'
          properties: {
            publicCertData: base64RootCert
          }
        }
      ]
    }
  }
  dependsOn: [
    snetGateway
  ]
}
