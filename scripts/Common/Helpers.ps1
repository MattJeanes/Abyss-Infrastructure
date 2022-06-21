$ErrorActionPreference = "Stop"

function Invoke-Kubectl {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string[]]$Parameters,

        [Parameter(Mandatory = $false)]
        [switch]$NoParse
    )

    if (-not $NoParse) {
        $null = $Parameters += "-o"
        $null = $Parameters += "json"
    }

    Write-Debug "Invoking kubectl with parameters $($Parameters -join ",")"

    try {
        $result = kubectl $Parameters
        if ($NoParse) {
            return $result
        }
        else {
            return $result | ConvertFrom-Json
        }
    }
    finally {
        if ($LASTEXITCODE -ne 0) {
            Write-Error "kubectl exited with code $LASTEXITCODE"
        }
    }
}

function Test-KubeCertificate {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,
        
        [Parameter(Mandatory = $false)]
        [string]$Namespace = "default"
    )

    $certificate = Invoke-Kubectl "get", "certificate", $Name, "--namespace", $Namespace
    $readyStatus = $certificate.status.conditions | Where-Object { $_.type -eq "Ready" }
    return $readyStatus.status -eq "True"
}

function Wait-KubeCertificate {
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

    $attempts = 0
    $maxAttempts = $TimeoutSeconds / $CheckInterval

    while (-not (Test-KubeCertificate -Name $Name -Namespace $Namespace)) {
        if ($attempts -ge $maxAttempts) {
            Write-Error "Certificate $Name in $Namespace is not ready after $TimeoutSeconds seconds"
        }
        $attempts++
        Write-Host "[$attempts/$maxAttempts] Certificate $Name in $Namespace is not yet ready"
        Start-Sleep -Seconds $CheckInterval
    }

    Write-Host "Certificate $Name in $Namespace is ready"
}