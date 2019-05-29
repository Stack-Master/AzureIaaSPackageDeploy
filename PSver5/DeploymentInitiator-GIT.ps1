Import-Module BitsTransfer

$Folder = "$PSScriptRoot\JSON"
If(!(Test-Path $Folder))
{
    New-Item -ItemType Directory -Force -Path $Folder
}
Start-BitsTransfer -source https://raw.githubusercontent.com/Stack-Master/AzureIaaSPackageDeploy/master/PSver5/IaaS-DeployPackagesPSV5.ps1
Start-BitsTransfer -source https://raw.githubusercontent.com/Stack-Master/AzureIaaSPackageDeploy/master/PSver5/config.json

#Packages
Start-BitsTransfer -source https://raw.githubusercontent.com/Stack-Master/AzureIaaSPackageDeploy/master/JSON/notepadpp.json -Destination $Folder
Start-BitsTransfer -Source https://raw.githubusercontent.com/Stack-Master/AzureIaaSPackageDeploy/master/JSON/chrome.json -Destination $Folder

& .\IaaS-DeployPackagesPSV5.ps1
