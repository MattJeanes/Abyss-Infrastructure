param(
    [Parameter(Mandatory = $true)]
    [string]$Url
)

. "$PSScriptRoot/Common/Helpers.ps1"

$request = [System.Net.WebRequest]::Create($Url)
$request.AllowAutoRedirect = $false
$response = $request.GetResponse()

if ($response.StatusCode -eq [System.Net.HttpStatusCode]::Redirect -and $response.Headers["Location"].StartsWith("https://abyss23.cloudflareaccess.com")) {
    Write-Host "Authentication redirect working for $Url"
}
else {
    Write-Error "Authentication redirect not working for $Url"
}