// Bicep module to add firewall rule into an App Service
@description('Name of the App Service to be configured with firewall rules')
param webAppName string

@description('Name of the firewall rule')
param ruleName string

@description('IPv4 addresses in CIDR to allow access')
param allowedIpList array

@description('IPv4 addresses in CIDR to allow access to SCM site')
param allowedIpListScm array

resource webApp 'Microsoft.Web/sites@2022-03-01' existing = {
  name: webAppName
}

var ipAddressesAllowed = [for (ip, ctr) in allowedIpList: {
  action: 'Allow'
  name: '${ruleName}-${ctr}'
  priority: (100+ctr)
  ipAddress: ip
}]

var ipAddressesScmAllowed = [for (ip, ctr) in allowedIpListScm: {
  action: 'Allow'
  name: '${ruleName}-${ctr}'
  priority: (100+ctr)
  ipAddress: ip
}]

resource firewallRules 'Microsoft.Web/sites/config@2022-03-01' = {
  parent: webApp
  name: 'web'
  properties: {
    ipSecurityRestrictions: ipAddressesAllowed
    scmIpSecurityRestrictions: ipAddressesScmAllowed
  }
}
