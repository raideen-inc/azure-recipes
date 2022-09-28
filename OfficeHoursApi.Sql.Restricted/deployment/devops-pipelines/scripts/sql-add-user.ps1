param (
  [string]$sqlAdmin,
  [string]$sqlPassword,
  [string]$resourceGroupName,
  [string]$deploymentName
)

# Get names from deployment
$outputs = (az deployment group show --resource-group $resourceGroupName --name $deploymentName `
  --query "{sqlSvrName:properties.outputs.sqlSvrName.value, sqlSvrFqdn:properties.outputs.sqlSvrFqdn.value, sqlDbName:properties.outputs.sqlDbName.value, webAppName:properties.outputs.webAppName.value}") 
  | ConvertFrom-Json

# Retrieve the App Id
# NOTE - Azure DevOps Service Principal need to have Directory.All.Read
$appSp = (az ad sp list --display-name $($outputs.webAppName)) | ConvertFrom-Json
$principalAppId = $appSp.appId

# hard-coded for testing
#$principalAppId = '062182d8-a4cf-47b2-9801-0979581e559f'

# convert to byte array
# Credit to: https://fgheysels.github.io/managed-identity-users-in-sql-via-devops/
[guid]$guid = [System.Guid]::Parse($principalAppId)
$byteGuid = "0x"
foreach ($byte in $guid.ToByteArray())
{
    $byteGuid += [System.String]::Format("{0:X2}", $byte)
}

# Open Sql Firewall for the agent
$agentIP = (New-Object net.webclient).downloadstring("https://api.ipify.org")
az sql server firewall-rule create --name 'agent-rule' --resource-group $resourceGroupName --server $outputs.sqlSvrName --start-ip-address $agentIP --end-ip-address $agentIP

# Execute Sql script - add user for managed identity
SqlCmd -S "tcp:$($outputs.sqlSvrFqdn),1433" -d $($outputs.sqlDbName) -U $sqlAdmin -P $sqlPassword -i 'managed-identity.sql' -v newUserName=$($outputs.webAppName) identitySid=$byteGuid

# Close Sql Firewall for the agent
az sql server firewall-rule delete --name 'agent-rule' --resource-group $resourceGroupName --server $outputs.sqlSvrName

