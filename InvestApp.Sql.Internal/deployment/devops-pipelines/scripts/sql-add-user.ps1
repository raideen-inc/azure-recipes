param (
  [string]$sqlAdmin,
  [string]$sqlPassword,
  [string]$resourceGroupName,
  [string]$deploymentName
)

function Add-User {
  param (
    [string]$userName
  )

  # Retrieve the App Id
  # NOTE - Azure DevOps Service Principal need to have Directory.All.Read
  $appSp = (az ad sp list --display-name $userName) | ConvertFrom-Json
  $principalAppId = $appSp.appId

  # convert to byte array
  # Credit to: https://fgheysels.github.io/managed-identity-users-in-sql-via-devops/
  [guid]$guid = [System.Guid]::Parse($principalAppId)
  $byteGuid = "0x"
  foreach ($byte in $guid.ToByteArray())
  {
      $byteGuid += [System.String]::Format("{0:X2}", $byte)
  }
  
  # No need to open & close firewall since Private Endpoint is used
  # Execute Sql script - add user for managed identity
  SqlCmd -S "tcp:$($outputs.sqlSvrFqdn),1433" -d $($outputs.sqlDbName) -U $sqlAdmin -P $sqlPassword -i 'managed-identity.sql' -v newUserName=$userName identitySid=$byteGuid
}  

# Get names from deployment
$outputs = (az deployment group show --resource-group $resourceGroupName --name $deploymentName `
  --query "{sqlSvrName:properties.outputs.sqlSvrName.value, sqlSvrFqdn:properties.outputs.sqlSvrFqdn.value, sqlDbName:properties.outputs.sqlDbName.value, webAppName:properties.outputs.webAppName.value, funcAppName:properties.outputs.funcAppName.value}") 
  | ConvertFrom-Json

Add-User -userName $($outputs.webAppName)
Add-User -userName $($outputs.funcAppName)


