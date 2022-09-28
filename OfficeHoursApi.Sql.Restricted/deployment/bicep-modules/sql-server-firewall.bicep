// Bicep module to add firewall rule into a SQL Logical Server
@description('Name of the SQL logical server')
param sqlSvrName string

@description('Name of the SQL logical server')
param ruleName string

@description('Starting & Ending IPv4 addresses of the firewall rule')
param ipAddresses array

resource sqlServer 'Microsoft.Sql/servers@2022-02-01-preview' existing = {
  name: sqlSvrName
}

resource firewallRules 'Microsoft.Sql/servers/firewallRules@2022-02-01-preview' = [for (ip, ctr) in ipAddresses: {
  parent: sqlServer
  name: '${ruleName}-${ctr}'
  properties: {
    startIpAddress: ip
    endIpAddress: ip
  }
}]

