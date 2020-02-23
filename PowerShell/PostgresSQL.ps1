$Service = Get-Service "postgresql*"

$ValidKey = 13
$KeyCode = 0

while($ValidKey -ne $KeyCode) {
    Clear-Host

    Write-Output "Service..: $($Service.Name)"
    Write-Output "Status...: $($Service.Status)"
    
    if($Service.Status -eq "Running") {
        Write-Host "Press ENTER to stop service" -ForegroundColor Green
    } elseif ($Service.Status -eq "Stopped") {
        Write-Host "Press ENTER to start service" -ForegroundColor Green
    }
    
    $KeyPress = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    $KeyCode = $KeyPress.VirtualKeyCode

    if($KeyCode -eq $ValidKey) {

        if($Service.Status -eq "Running") {
            Write-Host "Stopping Service..." -ForegroundColor Yellow
            $Service | Stop-Service
        } elseif ($Service.Status -eq "Stopped") {
            Write-Host "Starting Service..." -ForegroundColor Yellow
            $Service | Start-Service
        }

        Start-Sleep 5

    }
}