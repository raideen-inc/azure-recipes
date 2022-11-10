$subName = 'Azure Recipes Sub'
$rgName = 'rg-rdn-azurerecipes-dev'

$account = (az account show)
if (!$account)
{
    az login
    az account set --subscription $subName
}
az deployment group create --resource-group $rgName --template-file './main.bicep' --parameters './main-param-dev.json' 

#az deployment group create --resource-group $rgName --template-file './ARMTemplateForFactory.json' --parameters './ARMTemplateParametersForFactory.json' 

