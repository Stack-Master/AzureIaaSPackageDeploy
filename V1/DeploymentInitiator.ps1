Import-Module BitsTransfer
$Folder = "$PSScriptRoot\JSON"
If(!(Test-Path $Folder))
{
    New-Item -ItemType Directory -Force -Path $Folder
}
Start-BitsTransfer -source https://raw.githubusercontent.com/Stack-Master/AzureIaaSPackageDeploy/master/V1/IaaS-DeployPackages_V1.ps1
Start-BitsTransfer -source https://raw.githubusercontent.com/Stack-Master/AzureIaaSPackageDeploy/master/V1/config.json
Start-BitsTransfer -Source https://raw.githubusercontent.com/Stack-Master/AzureIaaSPackageDeploy/master/JSON/chrome.json -Destination $Folder
& .\IaaS-DeployPackages_V1.ps1 | Out-Null

