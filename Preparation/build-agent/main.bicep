@description('Location for Build Agent VM')
param location string = resourceGroup().location

@description('Name of Build Agent VM without prefix')
param vmNameNoPrefix string

@description('Name of the virtual network that has the Build Agent VM subnet')
param vnetName string

@description('Name of the subnet that the Build Agent VM reside')
param subnetName string

@description('Resource Group Name for the virtual network')
param rgNameForVnet string

@description('Name of the key vault for VM login & password')
param keyVaultName string

@description('Name of the computer used in Windows OS')
param osComputerName string

// Generate an unique value for naming the deployment
@description('String for uniqueness')
param unqiueUtc string = utcNow()

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

module vmBuildAgent './vm-win11.bicep' = {
  name: '${vnetName}-${unqiueUtc}'
  params:{
    vmLocation: location
    vmNameWithoutPrefix: vmNameNoPrefix
    computerName: osComputerName
    vnetName: vnetName
    subnetName: subnetName
    vmAdminLogin: keyVault.getSecret('ado-buildagent-login')
    vmAdminPassword: keyVault.getSecret('ado-buildagent-password')
    rgNameForVnet: rgNameForVnet
  }
}
