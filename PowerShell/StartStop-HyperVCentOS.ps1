#
# https://docs.microsoft.com/en-us/powershell/module/hyper-v/?view=win10-ps
#

$ValidKey = 13
$KeyCode = 0
$VMName = "CentOS 8"

function Get-KeyCode() {
    $KeyPress = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    return $KeyPress.VirtualKeyCode
}

function Invoke-StopVM {

    Stop-VM $VMName -AsJob | Out-Null            
    Write-Host "Stopping Virtual Machine..." -ForegroundColor Yellow -NoNewline

    do {
        $VM = Get-VM $VMName
        Write-Host "." -ForegroundColor Yellow -NoNewline
        Start-Sleep 1
    } until ($VM.State -eq "Off")
    
    Write-Host "Done!" -ForegroundColor Yellow -NoNewline
}

function Invoke-StartVM {

    Write-Host "Starting Virtual Machine." -ForegroundColor Yellow -NoNewline
    Start-VM $VMName -AsJob | Out-Null

    do {                
        $VM = Get-VM $VMName        
        Write-Host "." -ForegroundColor Yellow -NoNewline
        Start-Sleep 1
    } until ($VM.State -eq "Running")
    
    Write-Host "Done!" -ForegroundColor Yellow    
}

function Wait-ForVMNetwork {

    Write-Host "Waiting Virtual Machine Network." -ForegroundColor Yellow -NoNewline
    Start-VM $VMName -AsJob | Out-Null

    do {                
        $VMNetwork = Get-VMNetworkAdapter $VMName
        Write-Host "." -ForegroundColor Yellow -NoNewline
        Start-Sleep 2       
    } until ($VMNetwork.IPAddresses )
    
    Write-Host "Done!" -ForegroundColor Yellow
    return $VMNetwork
}

try {

    $VM = Get-VM -Name $VMName -ErrorAction Stop

    while ($ValidKey -ne $KeyCode) {
        Clear-Host

        Write-Output "Service..................: Hyper-V"
        Write-Output "Virtual Machine..........: $VMName [$($VM.State)]"
        
        if ($VM.State -eq "Running") {

            Write-Host "Press ENTER to Stop Virtual Machine" -ForegroundColor Green
            $KeyCode = Get-KeyCode
            Invoke-StopVM

        } elseif ($VM.State -eq "Off") {

            Write-Host "Press ENTER to Start Virtual Machine" -ForegroundColor Green
            $KeyCode = Get-KeyCode
            Invoke-StartVM
            $VMNet = Wait-ForVMNetwork
            Write-Output "Network..................: $($VMNet.IPAddresses)"
        }
    }
    
} catch {
    Write-Host "Script Error!" -ForegroundColor Red -BackgroundColor Black
    Write-Host "$($_.Exception.Message)" -ForegroundColor Red -BackgroundColor Black
    return
}