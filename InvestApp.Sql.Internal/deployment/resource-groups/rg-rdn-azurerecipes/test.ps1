$subName = 'Azure Recipes Sub'
$rgName = 'rg-demo-azurerecipes-dev'

$account = (az account show)
if (!$account)
{
    az login
    az account set --subscription $subName
}
az deployment group create --resource-group $rgName --template-file './main.bicep' --parameters './main-param-dev.json' 

# Clean up
# az network private-dns link vnet delete -g $rgName -z 'privatelink.azurewebsites.net' -n 'privatelink.azurewebsites.net-link' --yes
# az network private-dns link vnet delete -g $rgName -z 'privatelink.blob.core.windows.net' -n 'privatelink.blob.core.windows.net-link' --yes
# az network private-dns link vnet delete -g $rgName -z 'privatelink.vaultcore.azure.net' -n 'privatelink.vaultcore.azure.net-link' --yes
# az network private-dns link vnet delete -g $rgName -z 'privatelink.database.windows.net' -n 'privatelink.database.windows.net-link' --yes

#az keyvault purge --name kv-demo-invest-dev
