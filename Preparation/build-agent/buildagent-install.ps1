# Install and configure the Build Agent
param (
    [string] $PAT,
    [string] $agentFolder,
    [string] $poolName,
    [string] $buildAgentName
)

# Setting for configuring agent in Azure DevOps 
$adoOrgUrl = "https://dev.azure.com/<your-org>"
$buildAgentDownloadUrl = "https://vstsagentpackage.azureedge.net/agent/2.211.0/vsts-agent-win-x64-2.211.0.zip"

# configuration variables 
$agentZip = "vsts-agent.zip"

# Install Build Agent
mkdir $agentFolder
Set-Location $agentFolder
Invoke-WebRequest -Uri $buildAgentDownloadUrl -OutFile $agentZip
Expand-Archive -LiteralPath $agentZip -DestinationPath $agentFolder
.\config.cmd --unattended `
    --url $adoOrgUrl `
    --auth pat --token $PAT `
    --pool $poolName --agent $buildAgentName `
    --runAsService --windowsLogonAccount 'NT AUTHORITY\NETWORK SERVICE'
