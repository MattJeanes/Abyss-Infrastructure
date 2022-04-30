$ErrorActionPreference = "Stop"

function Test-Certificate {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,
        
        [Parameter(Mandatory = $false)]
        [string]$Namespace = "default"
    )

    $certificate = kubectl get certificate $Name --namespace $Namespace --output json | ConvertFrom-Json
    if ($LASTEXITCODE -ne 0) {
        Write-Error "kubectl exited with code $LASTEXITCODE"
    }
    $readyStatus = $certificate.status.conditions | Where-Object { $_.type -eq "Ready" }
    return $readyStatus.status
}
