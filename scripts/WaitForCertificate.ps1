param(
    [Parameter(Mandatory = $true)]
    [string]$CertificateName,
        
    [Parameter(Mandatory = $false)]
    [string]$Namespace = "default",

    [Parameter(Mandatory = $false)]
    [int]$TimeoutSeconds = 300,

    [Parameter(Mandatory = $false)]
    [int]$CheckInterval = 10
)

. "$PSScriptRoot\Common\Helpers.ps1"

$attempts = 0
$maxAttempts = $TimeoutSeconds / $CheckInterval

while (-not (Test-Certificate $CertificateName)) {
    if ($attempts -ge $maxAttempts) {
        Write-Error "Certificate is not ready after $TimeoutSeconds seconds"
    }
    $attempts++
    Write-Host "[$attempts/$maxAttempts] Certificate is not yet ready"
    Start-Sleep -Seconds $CheckInterval
}

Write-Host "Certificate is ready"
