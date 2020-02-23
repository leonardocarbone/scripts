$ValidKey = 13
$KeyCode = 0
$VMName = "CentOS"

function Get-Status([int]$Status) {
    
    switch ($Status) {
        1 { return "Stopped" }
        5 { return "Running" }
        6 { return "Paused" }
        9 { return "Starting" }
       10 { return "Stopping" }
       17 { return "Setting up" }
    }
}

function Get-KeyCode() {
    $KeyPress = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    return $KeyPress.VirtualKeyCode
}

try {
    $VBox = New-Object -ComObject "VirtualBox.VirtualBox"
    $VMSession = New-Object -ComObject "VirtualBox.Session"
    $VM = $VBox.FindMachine($VMName)
    
} catch {
    Write-Host "Script Initialization Error!" -ForegroundColor Red -BackgroundColor Black
    Write-Host "$($_.Exception.Message)" -ForegroundColor Red -BackgroundColor Black
    return
}


while ($ValidKey -ne $KeyCode) {
    Clear-Host

    $Status = Get-Status $VM.State

    Write-Output "Service..................: VirtualBox [Version $($VBox.Version)]"
    Write-Output "Virtual Machine..........: $($VM.Name) [$Status]"

    if ($Status -eq "Running") {
        Write-Host "Press ENTER to Stop Virtual Machine" -ForegroundColor Green
        $KeyCode = Get-KeyCode
        Write-Host "Stopping Virtual Machine..." -ForegroundColor Yellow
        $VM.LockMachine($VMSession, 1)
        $VMSession.Console.PowerButton()

    } elseif ($Status -eq "Stopped") {
        Write-Host "Press ENTER to Start Virtual Machine" -ForegroundColor Green
        $KeyCode = Get-KeyCode
        Write-Host "Starting Virtual Machine..." -ForegroundColor Green
        $VM.LaunchVMProcess($VMSession, "headless", "")
    } 

    Start-Sleep 5
}