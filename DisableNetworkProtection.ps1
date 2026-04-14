# DisableNetworkProtection.ps1
# Disables Defender network protection, allowing you to execute and visit websites, such as Steam.

$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Policy Manager"
$RegName = "EnableNetworkProtection"
$RegValue = 0 # Disabled = 0, Enabled = 1

Write-Host "Disable process starting..."

# Confirm path existance, if it doesn't exist, then create one
if (-not (Test-Path $RegPath)) {
    Write-Host "[*] RegPath not found, creating..."
    try {
        New-Item -Path $RegPath -Force | Out-Null
        Write-Host "[*] RegPath created"
    } catch {
        Write-Host "[-] RegPath creation failed: $_"
        exit 1
    }
} else {
    Write-Host "[*] RegPath already exists, creation skipped."
}

# Set value to disabled
try {
    Set-ItemProperty -Path $RegPath -Name $RegName -Value $RegValue -Type DWord -Force
    Write-Host "[+] '$RegName' set to $RegValue"
} catch {
    Write-Host "[-] Failed to set reg value: $_"
    exit 1
}

# Check if value was set
$CurrentValue = Get-ItemPropertyValue -Path $RegPath -Name $RegName -ErrorAction SilentlyContinue
if ($CurrentValue -eq $RegValue) {
    Write-Host "[+] Verification passed, network protection disabled."
} else {
    Write-Host "[-] Verification failed, current value: $CurrentValue"
}

Write-Host "" # New line
Write-Host "Process completed!"