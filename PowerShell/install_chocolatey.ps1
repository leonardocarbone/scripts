# Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

Start-Transcript -Path "install_chocolatey.log" -Force

$env:Path += ";C:\ProgramData\chocolatey\bin"

choco feature enable -n allowGlobalConfirmation

choco install speccy --ignore-checksums --params "/UseSystemLocale"
choco install cpu-z
choco install crystaldiskinfo
choco install crystaldiskmark
choco install hwinfo
choco install treesizefree
choco install 7zip

choco install powertoys
choco install speedtest-by-ookla
choco install foxitreader
choco install firefox

choco install starship ### cross-shell prompt
choco install git
choco install powershell-core
choco install vscode
choco install postman
choco install notepadplusplus

choco install whatsapp
choco install slack

# choco install dropbox
choco install googledrive

choco install spotify
choco install plexmediaserver
choco install vlc

choco install electrum
choco install simple-sticky-notes
choco install paint.net
choco install steam-client

choco install docker-desktop --ignore-package-exit-codes

Stop-Transcript