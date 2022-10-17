// Bicep module to provision a general purpose Windows 10 Virtual Machine
// ----------------------------------------------------------------------
@description('Location for the Windows 10 Virtual Machine')
param vmLocation string

@description('Name of the virtual machine without the vm- prefix')
param vmNameWithoutPrefix string

@description('Name of the virtual network that has the VM subnet')
param vnetName string

@description('Name of the subnet that the VM reside')
param subnetName string

@description('Resource Group Name for the virtual network')
param rgNameForVnet string

@minLength(5)
@maxLength(15)
@description('Windows computer name, 5 to 15 characters')
param computerName string

@description('The administrator username of the VM')
@secure()
param vmAdminLogin string

@description('The administrator password of the VM')
@secure()
param vmAdminPassword string

// Predefined values for general purpose VM
// https://docs.microsoft.com/en-us/azure/virtual-machines/linux/cli-ps-findimage
// offer => Windows-10, Windows-11, windows11preview Publisher => MicrosoftWindowsDesktop
// var vmSize = 'Standard_D2s_v5'
var vmSize = 'Standard_B2s'
var osVersion = 'win11-21h2-pro'
var winOffer = 'Windows-11'

// Generate Names
var vmName = 'vm-${vmNameWithoutPrefix}'
var nicName = 'nic-${vmNameWithoutPrefix}'

resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: vnetName
  scope: resourceGroup(rgNameForVnet)
}

resource snet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' existing = {
  name: subnetName
  parent: vnet
}

// Use P2S VPN instead of creating public ip
// var pipName = 'pip-${vmNameWithoutPrefix}'
// var dnsLabel = toLower(replace('${vmName}win10', '-', ''))
// resource pip 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
//   name: pipName
//   location: vmLocation
//   sku: {
//     name: publicIpSku
//   }
//   properties: {
//     publicIPAllocationMethod: publicIPAllocationMethod
//     dnsSettings: {
//       domainNameLabel: dnsLabel
//     }
//   }
// }

resource nic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: nicName
  location: vmLocation
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          // publicIPAddress: {
          //   id: pip.id
          // }
          subnet: {
            id: snet.id
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: vmName
  location: vmLocation
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: computerName
      adminUsername: vmAdminLogin
      adminPassword: vmAdminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: winOffer
        sku: osVersion
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
        name: '${vmName}-OsDisk'
      }
      dataDisks: [
        {
          diskSizeGB: 512
          lun: 0
          createOption: 'Empty'
          name: '${vmName}-DataDisk1'
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}
