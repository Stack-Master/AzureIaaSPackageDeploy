$Config = @{}
[string]$LogPath = $null
[string]$JSONPath = $null
Function Get-IaaSDeployConfig{
    $Config = @{}
    Foreach($File in Get-ChildItem $PSScriptRoot)
    {
        if($File.name -eq "config.json"){
            $Config = Get-Content -Raw -Path $PSScriptRoot\$File | ConvertFrom-JSON
        }
    }
    If(!$Config){
        Exit
    }
    return $Config
}
Function Get-TimeStamp {
	return "[{0:yyyy/MM/dd} {0:HH:mm:ss}]" -f (Get-Date)
}
Function Write-ToLog ($Value, $Type){
    Switch($Type){
    "0"{Add-Content -Path $LogPath -Value "$(Get-TimeStamp) [INFO] $Value";break}
    "1"{Add-Content -Path $LogPath -Value "$(Get-TimeStamp) [WARNING] $Value";break}
    "2"{Add-Content -Path $LogPath -Value "$(Get-TimeStamp) [ERROR] $Value";break}
    default{Add-Content -Path $LogPath -Value "$(Get-TimeStamp) [NOTSET] $Value";break}
    }
}
Function Get-IaasPackages ($JSONPath){
    $Packages =@{}
        If(!$JSONPath){
            Write-ToLog "Failed to verify path $JSONPath for packages." -Type 2
            Exit
        }
        Else{
            Write-ToLog "Verified $JSONPath as path" -Type 0
        }
        Foreach($Package in Get-ChildItem $JSONPATH){
            $IndexName = $Package.BaseName
            $Packages.$IndexName = Get-Content -Raw -Path $JSONPath\$Package | ConvertFrom-JSON
        }
        Clear-Variable Package
        Foreach($Package in $Packages.Keys){
            $VTL = $Packages[$Package].PackageName
            Write-ToLog "$VTL JSON   loaded successfully" -Type 0
        }
        Return $Packages
}
Function Get-IaaSPackageFiles ($Packages){
    $DownloadStatus = @{}
    Foreach($Package in $Packages.Keys){
            $DownloadStatus.$Package = "No"
            $VTL = $Packages[$Package].PackageLocation
            Write-ToLog "Downloading $VTL" -Type 0
            $url = $Packages[$Package].PackageLocation
            $output = $PSScriptRoot 
            $filename = Split-Path $url -leaf
            try{
            Invoke-WebRequest -Uri $url -OutFile $output\$filename -ErrorAction Stop
            Write-ToLog "Download Complete" -Type 0
            $DownloadStatus.$Package = $filename
            $Packages[$Package].PackageLocation = $filename
            }
            catch{
                Write-ToLog $_.Exception.Message -Type 2
            }
        }
    Foreach($item in $DownloadStatus.Keys){
        If ($DownloadStatus[$item] -eq "No")
        {
            Write-ToLog "$item package didnt download." -Type 2
        }
        Else
        {
            Write-ToLog "$item package downloaded." -Type 0
        }
    }
    Return $Packages
}
Function Install-IaaSPackages ($Packages){
    Foreach($item in $Packages.Keys){
        If($Packages[$item].PackageLocation -ne "Invalid"){
            $File = $Packages[$item].PackageLocation
            $Params = $Packages[$Item].PackageParams
            try{
                $Path = $PSScriptRoot
                Write-ToLog "Installing '$File' with parameters '$Params'" -Type 0
                & $Path\$File $Params | Out-Null
                Write-ToLog "Installation Run Successfully" -Type 0
            }catch{
                Write-ToLog $_.Exception.Message -Type 2
            }
        }
        else{
            $Name = $Packages[$item].PackageName
            Write-ToLog "Package $Name installer is invalid" -Type 2
        }
    }
}
$Config = Get-IaaSDeployConfig
$LogPath = $Config.LogPath
$JSONPath = "$PSScriptRoot\JSON"
$ProcessedPackages = Get-IaaSPackageFiles ($(Get-IaasPackages $JSONPath))
Install-IaaSPackages ($ProcessedPackages)