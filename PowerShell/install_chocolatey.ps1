# Set-ExecutionPolicy Bypass -Scope Process -Force
# [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

Start-Transcript -Path "install_chocolatey.log" -Force

$env:Path += ";C:\ProgramData\chocolatey\bin"

choco feature enable -n allowGlobalConfirmation

choco install speccy --ignore-checksums --params "/UseSystemLocale"
choco install cpu-z
choco install speedtest-by-ookla
choco install treesizefree
choco install paint.net
choco install steam-client
choco install vscode
choco install docker-desktop --ignore-package-exit-codes
choco install postman
choco install 7zip
choco install dropbox
choco install firefox
choco install foxitreader
choco install notepadplusplus
choco install plexmediaserver
choco install spotify
choco install vlc
choco install powershell-core
choco install powertoys
choco install git
choco install electrum
choco install crystaldiskinfo
choco install crystaldiskmark


Stop-Transcript