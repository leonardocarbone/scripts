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

Set-Location "C:\Documents and Settings"
Remove-Item ".\*\Local Settings\temp\*" -Recurse -Force -ErrorAction SilentlyContinue

Set-Location "C:\Users"
Remove-Item ".\*\Appdata\Local\temp\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item ".\*\Appdata\Local\Spotify\Data\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item ".\*\Appdata\Local\SourceServer\*" -Recurse -Force -ErrorAction SilentlyContinue

Set-Location "C:\Windows\Prefetch"
Remove-Item * -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "Done!"

Write-Host ">>> Removing Log Files....." -NoNewline
Set-Location "C:\Windows"
Remove-Item ".\Logs\*.log" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item ".\Logs\CBS\*.log" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item ".\Logs\MoSetup\*.log" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item ".\Panther\*.log" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item ".\INF\*.log" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item ".\SoftwareDistribution\*.log" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item ".\Microsoft.NET\*.log" -Recurse -Force -ErrorAction SilentlyContinue

Set-Location "c:\Users\$env:UserName\AppData\Local\Microsoft"
Remove-Item ".\Windows\WebCache\*.log" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item ".\Windows\SettingSync\*.log" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item ".\Windows\Explorer\ThumbCacheToDelete\*.log" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item ".\Windows\INetCache" -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "Done!"

Write-Host ">>> Removing EDGE Temp Files....." -NoNewline
Set-Location "c:\Users\$env:UserName\AppData\Local\Microsoft\Edge\User Data"
Remove-Item '.\Default\Cache\data*' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item '.\Default\Cache\f*' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item '.\Default\Cache\index*' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item '.\Default\Service Worker\Database' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item '.\Default\Service Worker\CacheStorage' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item '.\Default\Service Worker\ScriptCache' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item '.\Default\GPUCache' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item '.\Default\Storage\text' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item '.\GrShaderCache\GPUCache' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item '.\ShaderCache\GPUCache' -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "Done!"

Write-Host ">>> Removing BRAVE Temp Files....." -NoNewline
Set-Location "c:\Users\$env:UserName\AppData\Local\BraveSoftware\Brave-Browser\User Data"
Remove-Item '.\Default\Cache\data*' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item '.\Default\Cache\f*' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item '.\Default\Cache\index*' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item '.\Default\Service Worker\Database' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item '.\Default\Service Worker\CacheStorage' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item '.\Default\Service Worker\ScriptCache' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item '.\Default\GPUCache' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item '.\Default\Storage\text' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item '.\GrShaderCache\GPUCache' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item '.\ShaderCache\GPUCache' -Recurse -Force -ErrorAction SilentlyContinue



Write-Host "Done!"

Set-Location $CurrentDir

Write-Host ">>> Running Disk Clean up Tool"
#cleanmgr.exe


