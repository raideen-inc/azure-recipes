// Bicep module to provision a SQL database
// ----------------------------------------
@description('Location for the SQL logical server')
param sqlDbLocation string

@description('Name of the SQL logical server')
param sqlDbName string

@description('Name of the SQL logical server')
param sqlSvrName string

// Use the following az cli to determine the available sizing in your target region
// az sql db list-editions -l {location} -o table
@allowed([
  'basic'
  'medium'
  'high'
  'intense'
])
@description('Predefined sizing of the SQL database')
param sqlDbSize string

// Predefined a set of sizing for your organization
var dbSizeConfigure = {
  basic: {
    name: 'Basic'
    tier: 'Basic'
    size: 'Basic'
  }
  medium: {
    name: 'Standard'
    tier: 'Standard'
    size: 'S2'
  }
  high: {
    name: 'Standard'
    tier: 'Standard'
    size: 'S6'
  }
  intense: {
    name: 'Premium'
    tier: 'Premium'
    size: 'P6'
  }
}

resource sqlServer 'Microsoft.Sql/servers@2022-02-01-preview' existing = {
  name: sqlSvrName
}

resource sqlDB 'Microsoft.Sql/servers/databases@2022-02-01-preview' = {
  parent: sqlServer
  name: sqlDbName
  location: sqlDbLocation
  sku: {
    name: dbSizeConfigure[sqlDbSize].name
    tier: dbSizeConfigure[sqlDbSize].tier
    size: dbSizeConfigure[sqlDbSize].size
  }
}
