$env:Path += ";C:\ProgramData\chocolatey\bin"

Write-Host "[INFO] ... Installing Packages"
choco feature enable -n allowGlobalConfirmation
choco install packages.config

