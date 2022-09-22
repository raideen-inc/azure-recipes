$subName = '<your-subscription-name>'
$rgName = '<your-resource-group-name>'

$account = (az account show)
if (!$account)
{
    az login
    az account set --subscription $subName
}
az deployment group create --resource-group $rgName --template-file './main.bicep' --parameters './main-param-dev.json' 

