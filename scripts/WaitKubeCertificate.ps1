param(
    [Parameter(Mandatory = $true)]
    [string]$Name,
        
    [Parameter(Mandatory = $false)]
    [string]$Namespace = "default",

    [Parameter(Mandatory = $false)]
    [int]$TimeoutSeconds = 300,

    [Parameter(Mandatory = $false)]
    [int]$CheckInterval = 10
)

. "$PSScriptRoot/Common/Helpers.ps1"

Wait-KubeCertificate -Name $Name -Namespace $Namespace -TimeoutSeconds $TimeoutSeconds -CheckInterval $CheckInterval