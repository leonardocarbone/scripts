param (
    [switch]$Terminate
)

function Invoke-StopVM {

    param (
        [ValidateNotNullOrEmpty()]
        [string]$Name=$(throw "Parameter Required: [Name]")
    )

    Stop-VM $Name -AsJob | Out-Null            
    Write-Host "     Please Wait.." -NoNewline    

    do {
        $VM = Get-VM $Name
        Write-Host "." -NoNewline
        Start-Sleep 1
    } until ($VM.State -eq "Off")
    
    Write-Host "Done!"
}

$StoppedVMs = @()

$Configuration = (Read-Configuration | Set-DefaultConfiguration)

$Configuration.vms | ForEach-Object {

    if ( -not $_.enable) {
        Write-Warning "[$($_.name)] Disabled -> Skipped!!!"
        Write-Host " "
        return
    }

    $VM = Get-VM -Name $_.name -ErrorAction Ignore
    if ($null -eq $VM) {
        Write-Warning "[$($_.name)] Not Found -> Skipped!!!"
        return
    }
    
    Write-Host "[$($_.name)] VM Found!"
    Write-Host "[$($_.name)] Stopping VM"
    Invoke-StopVM -Name $_.name

    if ($Terminate.IsPresent) {
        
    }

    $StoppedVMs += $VM
    Write-Host " "
}

Write-Host " "
Write-Host " "
Write-Host "     ******************* SUMMARY *******************"
$StoppedVMs | ForEach-Object {
    Write-Host " "
    Write-Host "Name   : $($_.Name)"
    Write-Host "State  : $($_.State)"
}
Write-Host " "
Write-Host " "