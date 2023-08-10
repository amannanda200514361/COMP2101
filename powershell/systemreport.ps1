param (
    [switch]$System,
    [switch]$Disks,
    [switch]$Network
)

# Import necessary modules
Import-Module CimCmdlets

# Function to get system hardware
function Get-SystemHardware {
    if (-not $System) { return }
    $systemInfo = Get-CimInstance -ClassName Win32_ComputerSystem

    Write-Host "System Manufacturer: $($systemInfo.Manufacturer)"
    Write-Host "Model: $($systemInfo.Model)"
    Write-Host "Serial Number: $($systemInfo.SerialNumber)"
    # Add more properties as needed
}

# Function to get operating system information
function Get-OperatingSystem {
    if (-not $System) { return }
    $osInfo = Get-CimInstance -ClassName Win32_OperatingSystem

    Write-Host "Operating System: $($osInfo.Caption)"
    Write-Host "Version: $($osInfo.Version)"
    # Add more properties as needed
}

# Function to get processor information
function Get-Processor {
    if (-not $System) { return }
    $processorInfo = Get-CimInstance -ClassName Win32_Processor

    Write-Host "Processor: $($processorInfo.Name)"
    Write-Host "Number of Cores: $($processorInfo.NumberOfCores)"
    Write-Host "Speed: $($processorInfo.MaxClockSpeed) MHz"
    # Add more properties as needed
}

# Function to get memory information
function Get-Memory {
    if (-not $System) { return }
    $memoryInfo = Get-CimInstance -ClassName Win32_PhysicalMemory

    Write-Host "Memory:"
    foreach ($mem in $memoryInfo) {
        Write-Host "Bank/Slot: $($mem.BankLabel)/$($mem.DeviceLocator)"
        Write-Host "Manufacturer: $($mem.Manufacturer)"
        Write-Host "Description: $($mem.Description)"
        Write-Host "Capacity: $($mem.Capacity / 1GB) GB"
    }
    Write-Host ""
}

# Function to get network adapter configuration
function Get-NetworkAdapterConfiguration {
    if (-not $Network) { return }
    $networkAdapters = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled }

    Write-Host "Network Adapter Configuration:"
    foreach ($adapter in $networkAdapters) {
        Write-Host "Adapter Description: $($adapter.Description)"
        Write-Host "IP Address: $($adapter.IPAddress -join ', ')"
        Write-Host "Subnet Mask: $($adapter.IPSubnet -join ', ')"
        Write-Host "DNS Domain: $($adapter.DNSDomain)"
        Write-Host "DNS Servers: $($adapter.DNSServerSearchOrder -join ', ')"
        Write-Host ""
    }
}

# Function to get disk information
function Get-Disk {
    if (-not $Disks) { return }
    $diskDrives = Get-CimInstance -ClassName Win32_DiskDrive

    Write-Host "Disk Information:"
    foreach ($disk in $diskDrives) {
        $partitions = $disk | Get-CimAssociatedInstance -ResultClassName Win32_DiskPartition
        foreach ($partition in $partitions) {
            $logicalDisks = $partition | Get-CimAssociatedInstance -ResultClassName Win32_LogicalDisk
            foreach ($logicalDisk in $logicalDisks) {
                Write-Host "Drive: $($logicalDisk.DeviceID)"
                Write-Host "Size: $($logicalDisk.Size / 1GB) GB"
                Write-Host "Free Space: $($logicalDisk.FreeSpace / 1GB) GB"
                Write-Host "Percentage Free: $([Math]::Round(($logicalDisk.FreeSpace / $logicalDisk.Size) * 100))%"
                Write-Host ""
            }
        }
    }
}

# Report sections based on parameter values
if ($System) {
    Get-SystemHardware
    Get-OperatingSystem
    Get-Processor
    Get-Memory
}

if ($Disks) {
    Get-Disk
}

if ($Network) {
    Get-NetworkAdapterConfiguration
}
