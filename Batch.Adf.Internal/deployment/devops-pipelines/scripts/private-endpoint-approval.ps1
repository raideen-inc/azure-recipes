param (
    [string]$targetEnv,
    [string]$resourceGroupName
)

# Find out what are private endpoint resource based on the ADF parameter file
$param = Get-Content "adf-param-$targetEnv.json" | ConvertFrom-Json
$resourceList = $param.parameters |  Get-Member | Where-object { $_.Name -like "*_privateLinkResourceId"} | Select-Object Name

# For each resource, check if any pending approval, then approval it
foreach ($resource in $resourceList)
{
    $resourceId = $param.parameters.($resource.Name).value
    $pendingPe = (az network private-endpoint-connection list --id $resourceId `
        --query "[?properties.privateLinkServiceConnectionState.status == 'Pending'].id" --output tsv)
    foreach ($pe in $pendingPe) {
        Write-Host 'Approving' $pe
        az network private-endpoint-connection approve --id $pe --description 'Approved by CI/CD'
    }
}

