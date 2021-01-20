# https://docs.microsoft.com/en-us/powershell/module/hyper-v/?view=win10-ps

function Copy-TemplateDisk {

    param (
        [ValidateNotNullOrEmpty()]
        [string]$SourceFile=$(throw "Parameter Required: [SourceFile]"),

        [ValidateNotNullOrEmpty()]
        [string]$Destination=$(throw "Parameter Required: [Destination]"),

        [ValidateNotNullOrEmpty()]
        [string]$NewFileName=$(throw "Parameter Required: [NewFileName]")
    )
    
    if (-not (Test-Path -Path $SourceFile)) {
        throw "Copy-TemplateDisk: Source file [$SourceFile] does not exist"
    }
        
    
    if (-not (Test-Path -Path $Destination)) {
        throw "Copy-TemplateDisk: Destination [$Destination] does not exist"
    } elseif (-not ((Get-Item -Path $Destination) -is [System.IO.DirectoryInfo])) {
        throw "Copy-TemplateDisk: Destination [$Destination] must be a valid directory"
    }
    
    $DestinationFile = Join-Path -Path $Destination -ChildPath $NewFileName
    if (Test-Path -Path $DestinationFile) {
        throw "Copy-TemplateDisk: Destination file [$DestinationFile] already exists"
    }

    $FileSize = (Get-Item -Path $SourceFile).Length
    $FileSize = [string]::Format("{0:0.00} MB", $FileSize / 1MB)
    Write-Host "     Please Wait, Copying file [$FileSize]..."
  
    Copy-Item -Path $SourceFile -Destination $DestinationFile
        
    return $DestinationFile
}

function Invoke-NewVM {

    param (
        [ValidateNotNullOrEmpty()]
        [string]$Name=$(throw "Parameter Required: [Name]"),
    
        [ValidateNotNullOrEmpty()]
        [ValidateSet("1GB", "2GB", "4GB", "8GB")]
        [string]$MemorySize=$(throw "Parameter Required: [MemorySize]"),
    
        [ValidateNotNullOrEmpty()]
        [string]$DiskSize=$(throw "Parameter Required: [DiskSize]"),
    
        [ValidateNotNullOrEmpty()]
        [ValidateSet(1, 2)]
        [Int16]$Generation=$(throw "Parameter Required: [Generation]"),
    
        [ValidateNotNullOrEmpty()]
        [string]$NetworkSwitchName=$(throw "Parameter Required: [NetworkSwitchName]"),

        [ValidateNotNullOrEmpty()]
        [string]$VMPath=$(throw "Parameter Required: [VMPath]"),

        [ValidateNotNullOrEmpty()]
        [string]$VHDPath=$(throw "Parameter Required: [VHDPath]"),

        [string]$VHDFile=$(throw "Parameter Required: [VHDFile]"),

        [string]$ISOBootFile=$(throw "Parameter Required: [ISOBootFile]"),

        [bool]$EnableCheckpoint=$(throw "Parameter Required: [EnableCheckpoints]")
    )

    if (-not (Test-Path -Path $VMPath)) {
        throw "New-HyperVM: VM path [$VMPath] does not exist"
    } elseif (-not ((Get-Item $VMPath) -is [System.IO.DirectoryInfo])) {
        throw "New-HyperVM: VM path [$VMPath] must be a valid directory"
    }

    if (-not (Test-Path -Path $VHDPath)) {
        throw "New-HyperVM: VHD path [$VHDPath] does not exist"
    } elseif (-not ((Get-Item $VHDPath) -is [System.IO.DirectoryInfo])) {
        throw "New-HyperVM: VHD path [$VHDPath] must be a valid directory"
    }

    $NewVMVHD = $true
    if ( [string]::IsNullOrWhiteSpace($VHDFile)) {
    
        $VHDFile = Join-Path -Path $VHDPath -ChildPath "$Name.vhdx"
        
    } else {
        $NewVMVHD = $false
    
        if ( -not (Test-Path -Path $VHDFile)) {
            throw "New-HyperVM: File [$VHDFile] does not exist"
        }
    
        $VHDFileItem = Get-Item $VHDFile
        if ($VHDFileItem.Extension -ne ".vhdx") {
            throw "New-HyperVM: File [$VHDFile] must be .vhdx file"
        }
    }

    $BootFromISO = Test-Path -Path $ISOBootFile

    Write-Host " "
    Write-Host "     ******************* VM DETAILS *******************"
    Write-Host "     Name.......: $Name"
    Write-Host "     Generation.: $Generation"
    Write-Host "     Memory.....: $MemorySize"
    if ($NewVMVHD) { Write-Host "     Disk Size..: $DiskSize" }
    Write-Host "     Path.......: $VMPath"
    Write-Host "     VHD........: $VHDFile"
    if ($BootFromISO) { Write-Host "     Boot ISO...: $ISOBootFile" }
    Write-Host "     **************************************************"
    Write-Host " "

    if ($NewVMVHD) {
        $NewVM = New-VM -Name $Name -MemoryStartupBytes $MemorySize -Path $VMPath -NewVHDPath $VHDFile -NewVHDSizeBytes $DiskSize -Generation $Generation -SwitchName $NetworkSwitchName
    } else {
        $NewVM = New-VM -Name $Name -MemoryStartupBytes $MemorySize -Path $VMPath -VHDPath $VHDFile -Generation $Generation -SwitchName $NetworkSwitchName
    }

    if ($BootFromISO) {
        Add-VMDvdDrive -VMName $Name -Path $ISOBootFile
    }

    if ($Generation -eq 1) {
        Set-VMBios -VM $NewVM -EnableNumLock
    }elseif ($Generation -eq 2) {
        Set-VMFirmware -VM $NewVM -EnableSecureBoot On -SecureBootTemplate "MicrosoftUEFICertificateAuthority"
    }
    
    Set-VM -VM $NewVM -AutomaticCheckpointsEnabled $EnableCheckpoint -CheckpointType Disabled    
}

function Invoke-StartVM {

    param (
        [ValidateNotNullOrEmpty()]
        [string]$Name=$(throw "Parameter Required: [Name]")
    )

    Write-Host "     Please Wait.." -NoNewline

    Start-VM $Name -AsJob | Out-Null

    do {
        $VM = Get-VM $Name
        Write-Host "." -NoNewline
        Start-Sleep 1
    } until ($VM.State -eq "Running")
    
    Write-Host "Done!"
}

function Wait-ForVMIPAddresses {

    param (
        [ValidateNotNullOrEmpty()]
        [string]$Name=$(throw "Parameter Required: [Name]")
    )

    Write-Host "     Please Wait." -NoNewline   

    $TryCount = 0
    $MaxTryCount = 10
    do {
        $VMNetwork = Get-VMNetworkAdapter $Name
        Write-Host "." -NoNewline
        Start-Sleep 2
        $TryCount++
    } until ($VMNetwork.IPAddresses -or $TryCount -eq $MaxTryCount)
    
    if ($TryCount -eq $MaxTryCount) {
        Write-Host "Failed!"
        return $null
    }
    
    Write-Host "Done!" 
}

$CreatedVMs = @()


$Configuration = (Read-Configuration | Set-DefaultConfiguration)

$Configuration.vms | ForEach-Object {

    if ( -not $_.enable) {
        Write-Warning "[$($_.name)] Disabled -> Skipped!!!"
        Write-Host " "
        return
    }

    $VM = Get-VM -Name $_.name -ErrorAction Ignore
    if ($null -eq $VM) {

        if ( -not ([string]::IsNullOrWhiteSpace($_.from_template))) {

            $Template = ($Configuration.templates | Where-Object -Property name -eq $_.from_template)
            
            if ($null -eq $Template) {
                throw "Unable to create VM [$($_.name)] using template [$($_.from_template)]"
            }

            Write-Host "[$($_.name)] Importing Disk Template"
            $_.disk.attach_to = Copy-TemplateDisk -SourceFile $Template.file_path -Destination $_.paths.vhd -NewFileName "$($_.name).vhdx"
        }

        Write-Host "[$($_.name)] Creating new VM..."
        Invoke-NewVM -Name $_.name `
                     -MemorySize $_.memory `
                     -DiskSize $_.disk.size `
                     -Generation $_.generation `
                     -NetworkSwitchName $_.network.switch_name `
                     -VMPath $_.paths.vm `
                     -VHDPath $_.paths.vhd `
                     -VHDFile $_.disk.attach_to `
                     -ISOBootFile $_.boot_from_iso `
                     -EnableCheckpoint $_.enable_checkpoint

        $VM = Get-VM -Name $_.name -ErrorAction Ignore
        
        if ($null -eq $VM) {
            Write-Warning "[$($_.name)] Not Created -> Skipped!!!"
            return
        }
        else {
            Write-Host "[$($_.name)] Created!!!"
        }
    } else {
        Write-Host "[$($_.name)] VM Found!"
    }

    if ($_.auto_start) {
        Write-Host "[$($_.name)] Starting"
        Invoke-StartVM -Name $_.name

        Write-Host "[$($_.name)]  Waiting for network"
        Wait-ForVMIPAddresses -Name $_.name
    } else {
        Write-Host "[$($_.name)] Starting -> Skipped!!!"
        Write-Host "[$($_.name)] Waiting for network -> Skipped!!!"
    }

    $CreatedVMs += @{ name = $VM.name; state = $VM.state; memory_demand = $VM.MemoryDemand; memory_assigned = $VM.MemoryAssigned; ips = $VM.NetworkAdapters.IPAddresses }
    
    Write-Host " "
}

Write-Host " "
Write-Host " "
Write-Host "     ******************* SUMMARY *******************"
$CreatedVMs | ForEach-Object { 
    Write-Host " "
    Write-Host "Name            : $($_.name)"
    Write-Host "State           : $($_.state)"
    Write-Host "MemoryDemand    : $($_.memory_demand)"
    Write-Host "MemoryAssigned  : $($_.memory_assigned)"
    Write-Host "IPAddresses     : $($_.ips)"
    Write-Host " "
    Write-Host " => Connect using RDP, SSH or by typing 'vmconnect $($env:COMPUTERNAME) $($_.Name)'"
    Write-Host "---------- "
}
Write-Host " "
Write-Host " "