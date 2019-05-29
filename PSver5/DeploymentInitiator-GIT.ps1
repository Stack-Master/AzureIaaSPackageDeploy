Import-Module BitsTransfer
Start-BitsTransfer -source https://raw.githubusercontent.com/Stack-Master/AzureIaaSPackageDeploy/master/PSver5/IaaS-DeployPackagesPSV5.ps1
Start-BitsTransfer -source https://raw.githubusercontent.com/Stack-Master/AzureIaaSPackageDeploy/master/PSver5/config.json

& .\IaaS-DeployPackagesPSV5.ps1
