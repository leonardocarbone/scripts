function Get-KeyCode {
    $KeyPress = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    return $KeyPress.VirtualKeyCode
}

function Read-Configuration {

    $CONFIG_FILE = "hypervm-config.json"

    if (-not (Test-Path -Path $CONFIG_FILE)) {
        throw "Read-Configuration: File [$CONFIG_FILE] does not exist"
    }

    try {
        return (Get-Content -Path $CONFIG_FILE -Raw) | ConvertFrom-Json -Depth 20 -AsHashtable -ErrorAction Stop
    } catch {
        throw "Read-Configuration: File [$CONFIG_FILE] invalid"
    }
}

function Set-DefaultConfiguration {

    param ( [Parameter(ValueFromPipeline)]$Config )

    $VM_Host = Get-VMHost

    $DEFAULT_MEMORY = "1GB"
    $DEFAULT_GENERATION = 2
    $DEFAULT_DISK_SIZE = "10GB"
    $DEFAULT_SWITCH_NAME = "Default Switch"

    if (-not $Config.ContainsKey("templates")) { 
        $Config.templates = @() 
    } else {
        $Config.templates | ForEach-Object {
            if (-not $_.ContainsKey("name")) { $_.name = "" }
            if (-not $_.ContainsKey("file_path")) { $_.file_path = "" }
        }
    }
    
    $Config.vms | ForEach-Object {

        if (-not $_.ContainsKey("enable")) { $_.enable = $true }

        if (-not $_.ContainsKey("from_template")) { $_.from_template = "" }

        if (-not $_.ContainsKey("boot_from_iso")) { $_.boot_from_iso = "" }

        if (-not $_.ContainsKey("auto_start")) { $_.auto_start = $true }

        if (-not $_.ContainsKey("enable_checkpoint")) { $_.enable_checkpoint = $true }
        
        if (-not $_.ContainsKey("memory")) { $_.memory = $DEFAULT_MEMORY }
        
        if (-not $_.ContainsKey("generation")) { $_.generation = $DEFAULT_GENERATION }
        
        if (-not $_.ContainsKey("disk")) { 
            $_.disk = @{ size = $DEFAULT_DISK_SIZE; attach_to = "" }
        } else {
            if (-not $_.disk.ContainsKey("size")) { $_.disk.size = $DEFAULT_DISK_SIZE }
            if (-not $_.disk.ContainsKey("attach_to")) { $_.disk.attach_to = "" }
        }

        if (-not $_.ContainsKey("network")) {
            $_.network = @{ switch_name = $DEFAULT_SWITCH_NAME }
        } else {
            if (-not $_.network.ContainsKey("switch_name")) { $_.network.switch_name = $DEFAULT_SWITCH_NAME }
        }

        if (-not $_.ContainsKey("paths")) {
            $_.paths = @{ vm = $VM_Host.VirtualMachinePath; vhd = $VM_Host.VirtualHardDiskPath }
        } else {
            if (-not $_.paths.ContainsKey("vm")) { $_.paths.vm = $VM_Host.VirtualMachinePath }
            if (-not $_.paths.ContainsKey("vhd")) { $_.paths.vhd = $VM_Host.VirtualHardDiskPath }
        }
    }        
    return $Config
}