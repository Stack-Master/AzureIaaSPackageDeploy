
<#--

Script to deploy software packages to Azure VMs

Will accept JSON inputs for the packages to deploy. Two will be pre-pared as well as 
template for future packages to be put into. Packages should either be locally 
available or be available through the internet directly.

#? IaaS-DeployPackages -Log Database -JSONPath C:\Temp\IaaS -Silent

#!Logging
    Options for logging will be:
        * Logging to a local file
        * Logging to a database
        * Logging to LogAnalytics

#!Detection
    This script is not for the detection of VMs which havent had software deployed to
    a seperate set of scripts will be required, though this may be used as a part of
    those in that scenario.

#!Network
    Most software packages will require NSG changes for the VM and in some cases windows
    firewall changes. This will be included as part of the script and a requirement of
    the software package JSON

#!JSON Format (UPDATE WHERE APPROPRIATE)

{
    "PackageName":"sophoscloudagent",
    "PackageLocation":"https://example.etc/inf/iaas/packages/sophoscloudagent.msi",
    "NetworkRules": {
        "SourcePort":"443",
        "DestinationPort":"443",
        "SourceIP":"Any",
        "DestinationIP":"Any"
    }
}
--#>
# * Modules
Import-Module BitsTransfer

# * GLOBAL VARIABLES
# * Load Config.JSON for global variables
$Config = @{}
[string]$LogPath = $null
[string]$LogType = $null
[string]$JSONPath = $null
[string]$InstallPath = $null
[string]$NotificationEmail = $null

<#
$LogFile = $LogFile #Needs to be a file not a path
$LoggingType = 0 # 0 = Log File, 1 = SQL, 2 = LogAnalytics
#>

#* END OF GLOBAL VARIABLES
Function Get-IaaSDeployConfig{
    $Config = @{}
    Foreach($File in Get-ChildItem $PSScriptRoot)
    {
        if($File.name -eq "config.json"){
            $Config = Get-Content -Raw -Path $PSScriptRoot\$File | ConvertFrom-JSON
            Write-Host "Config Successfully found."
        }
    }
    If(!$Config){
        Write-Host "Config file doesnt exist or could not be found. ($PSScriptRoot)"
        Exit
    }
    return $Config
}
Function Get-TimeStamp { # Timestamp for logging
	return "[{0:yyyy/MM/dd} {0:HH:mm:ss}]" -f (Get-Date)
}
Function Write-ToLog ($Value, $Type){
    If($LogType -eq 0){
        Switch($Type){
        "0"{Add-Content -Path $LogPath -Value "$(Get-TimeStamp) [INFO] $Value";break}
        "1"{Add-Content -Path $LogPath -Value "$(Get-TimeStamp) [WARNING] $Value";break}
        "2"{Add-Content -Path $LogPath -Value "$(Get-TimeStamp) [ERROR] $Value";break}
        default{Add-Content -Path $LogPath -Value "$(Get-TimeStamp) [NOTSET] $Value";break}
        }
    }
    Elseif($LogType -eq 1){
        #TODO: SQL output
    }
    ElseIf($LogType -eq 2){
        #TODO: LogAnalytics output
    }
    Else{
        #! ERROR IDENTIFYING LOGGING TYPE
    }
}
Function Get-IaasPackages ($JSONPath){
    $Packages =@{}

        If(!$JSONPath){
            Write-Error "Failed to verify path $JSONPath for packages."
            Write-ToLog "Failed to verify path $JSONPath for packages." -Type 2
            Exit
        }
        Else{
            Write-Verbose "Verified $JSONPath as path"
            Write-ToLog "Verified $JSONPath as path" -Type 0
        }
        Foreach($Package in Get-ChildItem $JSONPATH){
            $IndexName = $Package.BaseName
            $Packages.$IndexName = Get-Content -Raw -Path $JSONPath\$Package | ConvertFrom-JSON
        }
        Write-Verbose "Following Packages have been loaded $Packages"
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
        #Write-Host Downloading $VTL
        Write-ToLog "Downloading $VTL" -Type 0
        $url = $Packages[$Package].PackageLocation
        $output = $PSScriptRoot 
        $filename = Split-Path $url -leaf
        try{
        Invoke-WebRequest -Uri $url -OutFile $output\$filename -ErrorAction Stop
        #Write-Host Download Complete
        Write-ToLog "Download Complete" -Type 0
        $DownloadStatus.$Package = $filename
        $Packages[$Package].PackageLocation = $filename
        }
        catch{
            Write-ToLog $_.Exception.Message -Type 2
        #    Write-Host "Download Failed"
        #    Write-ToLog "Download Failed"
        }
    }
    Foreach($item in $DownloadStatus.Keys){
        If ($DownloadStatus[$item] -eq "No")
        {
            #Write-Host $item package didnt download.
            Write-ToLog "$item package didnt download." -Type 2
        }
        Else
        {
            #Write-host $item package downloaded.
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
                & $Path\$File $Params
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
##$Directory = $PSScriptRoot
##Write-host $Directory

$Config = Get-IaaSDeployConfig
$LogPath = $Config.LogPath
$LogType = $Config.LogType
$JSONPath = $Config.JSONPath
$InstallPath = $Config.InstallPath
$NotificationEmail = $Config.NotificationEmail


$ProcessedPackages = Get-IaaSPackageFiles ($(Get-IaasPackages $JSONPath))
Install-IaaSPackages ($ProcessedPackages)


#$ITEST = Get-IaasPackages $JSONPath

