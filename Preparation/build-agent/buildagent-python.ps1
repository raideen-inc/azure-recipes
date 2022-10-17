# Install and configure Python for the Build Agent
param (
    [string] $agentFolder
)

# Software download Urls
$pythoniUrl = "https://www.python.org/ftp/python/3.10.6/python-3.10.6-amd64.exe"

# configuration variables 
$agentFolder = "C:\agents"
$exePython = "python-install.exe"

# Install Python
# Credit to: https://stackoverflow.com/users/11317673/timdadev @ https://stackoverflow.com/questions/60936103/install-python-to-self-hosted-windows-build-agent
# Note: make sure the version number is the same as in the path
$pythonInstallFolder = "$agentFolder\_work\_tool\Python\3.10.6\x64"
mkdir $pythonInstallFolder
Set-Location $pythonInstallFolder
Set-Location ..
Invoke-WebRequest -Uri $PythoniUrl -OutFile $exePython
&".\$exePython" /quiet InstallAllUsers=1 TargetDir=$pythonInstallFolder Include_launcher=0
"" > x64.complete