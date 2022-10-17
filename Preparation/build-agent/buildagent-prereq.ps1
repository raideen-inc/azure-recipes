# Install the 'base' software into the VM

# Software download Urls
$powerShellUrl = "https://github.com/PowerShell/PowerShell/releases/download/v7.2.5/PowerShell-7.2.5-win-x64.msi"
$dotNetiUrl = "https://download.visualstudio.microsoft.com/download/pr/9a1d2e89-d785-4493-aaf3-73864627a1ea/245bdfaa9c46b87acfb2afbd10ecb0d0/dotnet-sdk-6.0.400-win-x64.exe"
$azureCliUrl = "https://aka.ms/installazurecliwindows"
$sqlCmdUrl = "https://go.microsoft.com/fwlink/?linkid=2142258"
$odbcUrl = "https://go.microsoft.com/fwlink/?linkid=2200731"
$vc2017Url = "https://aka.ms/vs/15/release/vc_redist.x64.exe"

# Command to be executed for installation
$msiPowerShell = "PowerShell.msi"
$msiAzureCli = "AzureCli.msi"
$exeDotNet = "dotnet-install.exe"
$msiSqlCmd = "MsSqlCmdLnUtils.msi"
$msiOdbc = "msodbcsql.msi"
$exeVc2017 = "vc_redist.x64.exe"

mkdir C:\Temp
Set-Location C:\Temp

# Install PowerShell and enable automated update via Windows Update
Invoke-WebRequest -Uri $PowerShellUrl -OutFile $msiPowerShell
msiexec.exe /package $msiPowerShell /quiet /log .\powershell.log ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ADD_FILE_CONTEXT_MENU_RUNPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1 USE_MU=1 ENABLE_MU=1

# Install Azure CLI
Invoke-WebRequest -Uri $AzureCliUrl -OutFile $msiAzureCli
msiexec.exe /package $msiAzureCli /quiet /log .\azurecli.log

# Install dotNet
Invoke-WebRequest -Uri $DotNetiUrl -OutFile $exeDotNet
&".\$exeDotNet" /install /quiet /norestart

# Install Visual C++ 2017 redistribution
Invoke-WebRequest -Uri $vc2017Url -OutFile $exeVc2017
&".\$exeVc2017" /install /quiet /norestart

# Install ODBC
Invoke-WebRequest -Uri $odbcUrl -OutFile $msiOdbc
msiexec.exe /package $msiOdbc /quiet /norestart /log .\odbc.log IACCEPTMSODBCSQLLICENSETERMS=YES 

# Install SQL Cmd
Invoke-WebRequest -Uri $sqlCmdUrl -OutFile $msiSqlCmd
msiexec.exe /package $msiSqlCmd /quiet /log .\sqlcmd.log IACCEPTMSSQLCMDLNUTILSLICENSETERMS=YES 