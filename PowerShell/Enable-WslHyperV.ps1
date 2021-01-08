$WSLInterface = "vEthernet (WSL)"
$HyperVInterface = "vEthernet (Default Switch)"
Get-NetIPInterface | where {$_.InterfaceAlias -eq $WSLInterface -or $_.InterfaceAlias -eq $HyperVInterface} | Set-NetIPInterface -Forwarding Enable