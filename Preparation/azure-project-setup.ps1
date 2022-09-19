# This script to automate the prep works for Azure Services
# For each environment,
# - create a resource group
# - create a key vault

# Update the variables below according to your setting
$rgName = '<your-resource-group>'
$kvName = '<your-key-vault>'
$kvRetentionDay = 7
$environmentList = @(
    @{ name='dev'; subscription='<your-dev-subscription>'; location='<your-dev-region>' }
    @{ name='test'; subscription='<your-test-subscription>'; location='<your-test-region>' }
    @{ name='prod'; subscription='<your-prod-subscription>'; location='<your-prod-region>' }
)

# Login to Azure if needed
$account = (az account show)
if (!$account)
{
    az login
}

# Create base Azure Services in each environment
foreach ($env in $environmentList)
{
    $rgFullName = ($rgName + '-' + $env.name)
    $kvFullName = ($kvName + '-' + $env.name)
    az account set --subscription $env.subscription
    az group create --location $env.location --name $rgFullName 
    az keyvault create --resource-group $rgFullName --name $kvFullName --retention-days $kvRetentionDay
}
