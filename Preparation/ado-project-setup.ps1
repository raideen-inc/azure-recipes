# This script to automate the prep works for Azure DevOps:
# - create an Azure DevOps project
# - initialize the Repo with main and develop branch
# - create 3 environments for CI/CD

# Update the variable according to your setting
$orgURL = 'https://dev.azure.com/<your-org>'
$projName = '<your-proj>'
$projDesc = '<your-description>'
$projProcess = 'Scrum'

# Create a new project, and set it as default
az devops configure --defaults organization=$orgURL
az devops project create --org $orgURL --name $projName --description $projDesc --process $projProcess
az devops configure --defaults project=$projName

# Initialize Repo with main and develop branch
git config --global init.defaultBranch main
git clone (az repos list --query [0].webUrl)
Set-Location ".\$projName"
$projName > Readme.md
git add .
git commit -m "Initialize Repo"
git push
git branch develop main
git checkout develop
"$projDesc" >> .\Readme.md
git add .
git commit -m "Added develop branch"
git push --set-upstream origin develop

# credit to: https://colinsalmcorner.com/az-devops-like-a-boss/
# https://docs.microsoft.com/en-us/rest/api/azure/devops/distributedtask/environments/add?view=azure-devops-rest-6.0 
# Create environments
$environmentList = 'DEV', 'TEST', 'PROD'
foreach ($env in $environmentList)
{
    $requestBody = @{
        name = $env
        description = "This is $env environment"
    }
    $infile = "requestBody.json"
    Set-Content -Path $infile -Value ($requestBody | ConvertTo-Json)
    az devops invoke `
        --http-method POST --in-file $infile `
        --area distributedtask --resource environments `
        --route-parameters project=$projName --api-version "6.0" `
}
Remove-Item $infile

# TODO: Add approval for environment
# https://docs.microsoft.com/en-us/rest/api/azure/devops/approvalsandchecks/check-configurations?view=azure-devops-rest-7.1
