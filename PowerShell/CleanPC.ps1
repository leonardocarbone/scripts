$CurrentDir = Get-Location

Clear-Host

Write-Host "Performing Cleanup..."

Write-Host ">>> Emptying Recycle Bin....." -NoNewline
$RecycleBin = (New-Object -ComObject Shell.Application).Namespace(0XA)
$RecycleBin.Items() | %{ Remove-Item $_.Path -Recurse -Confirm:$false }
Write-Host "Done!"

Write-Host ">>> Removing Temp Files....." -NoNewline
Set-Location "C:\Windows\Temp"
Remove-Item * -Recurse -Force -ErrorAction SilentlyContinue

Set-Location "C:\Windows\Prefetch"
Remove-Item * -Recurse -Force -ErrorAction SilentlyContinue

Set-Location "C:\Documents and Settings"
Remove-Item ".\*\Local Settings\temp\*" -Recurse -Force -ErrorAction SilentlyContinue

Set-Location "C:\Users"
Remove-Item ".\*\Appdata\Local\temp\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item ".\*\Appdata\Local\Spotify\Data\*" -Recurse -Force -ErrorAction SilentlyContinue


Write-Host "Done!"

Set-Location $CurrentDir

Write-Host ">>> Running Disk Clean up Tool"
cleanmgr.exe


