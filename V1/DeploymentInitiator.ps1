Import-Module BitsTransfer
Start-BitsTransfer -Source https://raw.githubusercontent.com/Stack-Master/AzureIaaSPackageDeploy/master/directory.json
$Directory = @{}
$Directory = Get-Content -Raw -Path $PSScriptRoot\directory.json | ConvertFrom-JSON
If(!$Directory){
     Exit
}
$Folder = "$PSScriptRoot\JSON"
If(!(Test-Path $Folder))
{
    New-Item -ItemType Directory -Force -Path $Folder
}
foreach ($Key in $Directory.Keys)
{
    If($Directory[$Key].BaseName -eq "main"){
        Start-BitsTransfer -Source $Directory[$Key].config
        Start-BitsTransfer -Source $Directory[$Key].deploy
    }
    else{
        Start-BitsTransfer -Source $Directory[$Key].location -Destination $Folder
    }
}
$MainDeployPayload = Split-Path $Directory["main"].deploy -leaf
& .\$MainDeployPayload | Out-Null

