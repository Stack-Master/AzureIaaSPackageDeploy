
$currentdir = $PSScriptRoot
$Output = "$currentdir\AzureIaaSPackageDeploy-master.zip"

$wc = New-Object System.Net.WebClient
$wc.DownloadFile("http://github.com/Stack-Master/AzureIaaSPackageDeploy/archive/master.zip", $Output)

Expand-Archive "AzureIaaSPackageDeploy-master.zip" -Force

Set-Location "$currentdir\AzureIaaSPackageDeploy-master\"

& .\IaaS-DeployPackages.ps1
Write-Host "Ran!"