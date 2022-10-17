$subName = 'Azure Recipes Sub'
$env = 'dev'
$rgName = "rg-demo-networking-$env"

$account = (az account show)
if (!$account)
{
    az login
    az account set --subscription $subName
}
az deployment group create --resource-group $rgName --template-file './main.bicep' --parameters "./main-param-$env.json" --parameters environmentName=$env

# force a update to create P2S configuration
az network vnet-gateway update -g $rgName -n "vpng-demo-azurerecipes-$env"