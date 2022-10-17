# Reference: 
# Self-hosted Windows build agent: https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/v2-windows?view=azure-devops
# Permission required for run-command invoke: https://docs.microsoft.com/en-us/azure/virtual-machines/windows/run-command#limiting-access-to-run-command

# environment suffix, e.g. dev, test, prod
$env = 'test'
# Secure store for automation
$kvName = 'kv-demo-azurerecipes'
# Build agent installation folder
$agentFolder = "C:\agents"

# Settings for provisioning Virtual Machine 
$rgName = 'rg-demo-azurerecipes'
$buildAgentRawName = 'demo-buildagent'
$vnetName = 'vnet-demo-azurerecipes'
$snetName = 'snet-vm'
$rgNameForVnet = 'rg-demo-networking'
$patName = 'ado-buildagent-pat'
$osComputerName = 'AdoAgent01'
$buildAgentName = "agent-win11-01-$env"
$poolName = "Default-$env"

# ---------------------------------------------------------
# Provision Build Agent VM
$rgFullName = "$rgName-$env"
$vnetFullName = "$vnetName-$env"
$snetFullName = "$snetName-$env"
$rgFullNameForVnet = "$rgNameForVnet-$env"
$vmFullNameNoPrefix = "$buildAgentRawName-$env"
$vmFullName = "vm-$buildAgentRawName-$env"
$kvFullName = "$kvName-$env"
$osComputerFullName = "$osComputerName$env"

Write-Host "STARTING: az deployment" (Get-Date) -ForegroundColor Green
az deployment group create --resource-group $rgFullName `
    --template-file './main.bicep' `
    --parameters vmNameNoPrefix=$vmFullNameNoPrefix --parameters osComputerName=$osComputerFullName `
    --parameters vnetName=$vnetFullName --parameters subnetName=$snetFullName `
    --parameters keyVaultName=$kvFullName --parameters rgNameForVnet=$rgFullNameForVnet
Write-Host "COMPLETED: az deployment" (Get-Date) -ForegroundColor Green

# ---------------------------------------------------------
# Install base software, PS, Azure CLI and dotnet
Write-Host "STARTING: install base software" (Get-Date) -ForegroundColor Green
az vm run-command invoke --resource-group $rgFullName --name $vmFullName `
    --command-id RunPowerShellScript --scripts @buildagent-prereq.ps1 
# Ensure silent installation are all completed
Start-Sleep -Seconds 60
Write-Host "COMPLETED: install base software" (Get-Date) -ForegroundColor Green

# ---------------------------------------------------------
# Download, install and configure Build Agent

# Get PAT for agent configuration from Key Vault
$PAT = az keyvault secret show --name $patName --vault-name $kvFullName --query value

# # Install and configure build agent
Write-Host "STARTING: configure build agent" (Get-Date) -ForegroundColor Green
az vm run-command invoke --resource-group $rgFullName --name $vmFullName `
    --command-id RunPowerShellScript --scripts @buildagent-install.ps1 `
    --parameters "pat=$PAT" "agentFolder=$agentFolder" "buildAgentName=$buildAgentName" "poolName=$poolName"
Write-Host "COMPLETED: configure build agent" (Get-Date) -ForegroundColor Green

# Install and configure Python for build agent
Write-Host "STARTING: install Python" (Get-Date) -ForegroundColor Green
az vm run-command invoke --resource-group $rgFullName --name $vmFullName `
    --command-id RunPowerShellScript --scripts @buildagent-python.ps1 `
    --parameters "agentFolder=$agentFolder"
Write-Host "COMPLETED: install Python" (Get-Date) -ForegroundColor Green
