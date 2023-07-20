# Get a collection of network adapter configuration objects
$networkAdapters = Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled }

# Create a custom object for each adapter with the required properties
$reportData = $networkAdapters | ForEach-Object {
    [PSCustomObject]@{
        'Adapter Description' = $_.Description
        'Index' = $_.Index
        'IP Address' = $_.IPAddress -join ', '
        'Subnet Mask' = $_.IPSubnet -join ', '
        'DNS Domain Name' = $_.DNSDomain
        'DNS Server' = $_.DNSServerSearchOrder -join ', '
    }
}

# Format and display the report as a table
$reportData | Format-Table -AutoSize
