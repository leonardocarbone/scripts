#
# https://docs.microsoft.com/en-us/powershell/module/hyper-v/?view=win10-ps
#

$ValidKey = 13
$KeyCode = 0

function Get-KeyCode() {
    $KeyPress = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    return $KeyPress.VirtualKeyCode
}

function Invoke-StopVM([string]$Name) {

    Stop-VM $Name -AsJob | Out-Null            
    Write-Host "Stopping Virtual Machine [$Name]..." -ForegroundColor Yellow -NoNewline

    do {
        $VM = Get-VM $Name
        Write-Host "." -ForegroundColor Yellow -NoNewline
        Start-Sleep 1
    } until ($VM.State -eq "Off")
    
    Write-Host "Done!" -ForegroundColor Yellow -NoNewline
}

function Invoke-StartVM([string]$Name) {

    Write-Host "Starting Virtual Machine [$Name]." -ForegroundColor Yellow -NoNewline

    Start-VM $Name -AsJob | Out-Null

    do {                
        $VM = Get-VM $Name        
        Write-Host "." -ForegroundColor Yellow -NoNewline
        Start-Sleep 1
    } until ($VM.State -eq "Running")
    
    Write-Host "Done!" -ForegroundColor Yellow    
}

function Wait-ForVMNetwork([string]$Name) {

    Write-Host "Waiting Virtual Machine Network." -ForegroundColor Yellow -NoNewline
    Start-VM $Name -AsJob | Out-Null

    do {                
        $VMNetwork = Get-VMNetworkAdapter $Name
        Write-Host "." -ForegroundColor Yellow -NoNewline
        Start-Sleep 2       
    } until ($VMNetwork.IPAddresses )
    
    Write-Host "Done!" -ForegroundColor Yellow
    return $VMNetwork
}

try {    

    $VMs = Get-VM -Name "*Cento*"
    if(-not $VMs) {
        Write-Host "CentOS VMs not found!" -ForegroundColor Red
        return
    }
    
    while ($true) {
        Clear-Host
        Write-Host "Select CentOS VM (ESC to Cancel)"
        Write-Host " "

        $Options = @{}
        $Count = 1
        $VMs | ForEach-Object {
            
            if ($_.State -eq "Off") { 
                Write-Host "$Count - $($_.Name) [$($_.State)]" 
            } elseif ($_.State -eq "Running") {
                $VMNet = Get-VMNetworkAdapter $_.Name
                Write-Host "$Count - $($_.Name) [$($_.State)] [$($VMNet.IPAddresses)]"
            }
            
            $Options[[byte][char]"$Count"] = @{ 
                Name = $_.Name
                State = $_.State
            }
            
            $Count++
        }
        
        [byte]$KeyCode = Get-KeyCode
        
        # Test ESC - Cancel
        if($KeyCode -eq 27) { return }

        if($Options.ContainsKey($KeyCode)) { 

            Write-Host " "
            if($Options[$KeyCode].State -eq "Running") {
                
                Invoke-StopVM -Name $Options[$KeyCode].Name 
                
            } elseif ($Options[$KeyCode].State -eq "Off") {
                
                Invoke-StartVM -Name $Options[$KeyCode].Name
                Wait-ForVMNetwork -Name $Options[$KeyCode].Name | Out-Null
            }
        } else {
            Write-Host "Invalid Option!!" -ForegroundColor Red
            Start-Sleep 1
        }
    } 


        
    
    <#
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
    }#>
    
} catch {
    Write-Host "Script Error!" -ForegroundColor Red -BackgroundColor Black
    Write-Host "$($_.Exception.Message)" -ForegroundColor Red -BackgroundColor Black
    return
}