# Check for administrative privileges
$currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "This script requires administrative privileges. Please run as Administrator."
    pause
    exit
}

# Check execution policy
$executionPolicy = Get-ExecutionPolicy
if ($executionPolicy -ne 'Unrestricted' -and $executionPolicy -ne 'RemoteSigned') {
    $changePolicy = Read-Host "The current execution policy may prevent this script from running. Do you want to change it to RemoteSigned? (Y/N)"
    if ($changePolicy -eq 'Y') {
        Set-ExecutionPolicy RemoteSigned -Force
    } else {
        Write-Host "Operation cancelled by the user."
        exit
    }
}

# Confirmation prompt
$confirmation = Read-Host "This script will modify power settings and registry values. Do you want to continue? (Y/N)"
if ($confirmation -ne 'Y') {
    Write-Host "Operation cancelled by the user."
    exit
}

# Registry path to the GUID
$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\be337238-0d82-4146-a960-4f3749d470c7"

# Get the current value of the Attributes
$currentAttributesValue = Get-ItemProperty -Path $registryPath -Name "Attributes" | Select-Object -ExpandProperty "Attributes"

# Check if the current value is 1, and update it to 2 if so
if ($currentAttributesValue -eq 1) {
    $attributesValue = 2
    Set-ItemProperty -Path $registryPath -Name "Attributes" -Value $attributesValue
}

# Get all power plans
$powerPlans = powercfg /list | Select-String -Pattern 'Power Scheme GUID: (\S+)'

# Get a sample plan to query for the subgroup GUID
$samplePlan = $powerPlans.Matches[0].Groups[1].Value

# Query the sample plan details
$powerSchemeDetails = powercfg /query $samplePlan

# Extract the processor power management subgroup GUID
$processorSubgroup = ($powerSchemeDetails | Select-String -Pattern 'Subgroup GUID:\s*(\S+)\s*\(Processor power management\)').Matches[0].Groups[1].Value

# Desired value to disable boost mode (corresponding to "Disabled" index, in hexadecimal format)
$disableBoostValue = "0x00000000"

# Check if all plans are already disabled
$allPlansDisabled = $true

# Loop through each power plan and make the changes
foreach ($plan in $powerPlans.Matches) {
    $currentPlan = $plan.Groups[1].Value
    powercfg /setactive $currentPlan
    $powerSchemeDetails = powercfg /query
    $boostModeLine = $powerSchemeDetails | Select-String -Pattern 'Power Setting GUID:\s*(\S+)\s*\(Processor performance boost mode\)'
    $boostModeSetting = $boostModeLine.Matches[0].Groups[1].Value
    $currentACValue = ($powerSchemeDetails | Select-String -Pattern "Current AC Power Setting Index: (\S+)").Matches[0].Groups[1].Value

    if ($currentACValue -ne $disableBoostValue) {
        powercfg /setacvalueindex $currentPlan $processorSubgroup $boostModeSetting $disableBoostValue
        powercfg /setdcvalueindex $currentPlan $processorSubgroup $boostModeSetting $disableBoostValue
        $allPlansDisabled = $false
    }
}

if ($allPlansDisabled) {
    Write-Host "Processor performance boost mode is already disabled for all plans."
} else {
    Write-Host "Processor performance boost mode disabled for applicable plans."
}
