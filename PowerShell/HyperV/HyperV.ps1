param (
    [switch]$Up,
    [switch]$Down,
    [switch]$Terminate
)

function Show-Help {
    Write-Host " "
    Write-Host "Usage..: .\HyperV.ps1 [ -Up | -Down | -Terminate ]"
    Write-Host " "
}

. .\Private\Common.ps1

if ($Up.IsPresent -and $Down.IsPresent -and $Terminate.IsPresent) {
    Show-Help
} elseif ($Up.IsPresent) {
    .\Private\Invoke-Up.ps1
} elseif ($Down.IsPresent) {
    .\Private\Invoke-Down.ps1
} elseif ($Terminate.IsPresent)  {
    .\Private\Invoke-Down.ps1 -Terminate
} else {
    Show-Help
}