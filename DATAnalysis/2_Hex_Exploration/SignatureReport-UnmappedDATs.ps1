Add-Type -AssemblyName System.Windows.Forms

$scriptDirectory = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$unmappedListFile = Join-Path -Path $scriptDirectory -ChildPath "..\1_Core_Pipeline\FFXI_Unmapped_Local_DATs.txt"
$signatureReportFile = Join-Path -Path $scriptDirectory -ChildPath "FFXI_Unknown_Signatures.txt"

if (-not (Test-Path $unmappedListFile)) {
    Write-Host "Could not find Unmapped List. Make sure it is in 1_Core_Pipeline!" -ForegroundColor Red
    return
}

# --- 1. Find FFXI Install Directory ---
$registryPaths = @("HKLM:\SOFTWARE\WOW6432Node\PlayOnlineUS\InstallFolder", "HKLM:\SOFTWARE\WOW6432Node\PlayOnlineEU\InstallFolder", "HKLM:\SOFTWARE\WOW6432Node\PlayOnline\InstallFolder")
$ffxiPath = $null
foreach ($path in $registryPaths) { if (Test-Path $path) { $ffxiPath = (Get-ItemProperty -Path $path -Name "0001" -ErrorAction SilentlyContinue)."0001"; if ($ffxiPath) { break } } }

if (-not $ffxiPath) {
    $ffxiBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $ffxiBrowser.Description = "Select your FINAL FANTASY XI folder:"
    if ($ffxiBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { $ffxiPath = $ffxiBrowser.SelectedPath } else { return }
}

# --- 2. Read Unmapped List & Inspect Headers ---
Write-Host "Inspecting Hex Headers..."
$unmappedLines = Get-Content -Path $unmappedListFile | Where-Object { $_ -match "^ROM" }
$signatureGroups = @{}

foreach ($relativePath in $unmappedLines) {
    $localPath = Join-Path -Path $ffxiPath -ChildPath ($relativePath -replace '/', '\')
    $localPath = "$localPath.DAT"
    
    if (Test-Path $localPath -PathType Leaf) {
        try {
            $bytes = Get-Content -Path $localPath -Encoding Byte -TotalCount 4 -ErrorAction Stop
            $hexSig = if ($bytes.Count -eq 0) { "[EMPTY FILE]" } else { [System.BitConverter]::ToString($bytes) -replace '-', ' ' }
            if (-not $signatureGroups.ContainsKey($hexSig)) { $signatureGroups[$hexSig] = New-Object System.Collections.Generic.List[string] }
            $signatureGroups[$hexSig].Add($relativePath)
        } catch {
            if (-not $signatureGroups.ContainsKey("[UNREADABLE]")) { $signatureGroups["[UNREADABLE]"] = New-Object System.Collections.Generic.List[string] }
            $signatureGroups["[UNREADABLE]"].Add($relativePath)
        }
    }
}

# --- 3. Output Report ---
Write-Host "Building Signature Report..."
$sortedSignatures = $signatureGroups.GetEnumerator() | Sort-Object { $_.Value.Count } -Descending

$reportContent = @("=================================================", " FFXI Unmapped Files - Hex Signature Profiler", " Total Files Inspected: $($unmappedLines.Count)", "=================================================", "")

foreach ($group in $sortedSignatures) {
    $sig = $group.Key
    $count = $group.Value.Count
    $examples = $group.Value | Select-Object -First 5
    $exampleString = $examples -join ", "
    if ($count -gt 5) { $exampleString += "... (and $($count - 5) more)" }
    $reportContent += "Signature: [$sig] - Found $count files`nExamples:  $exampleString`n-------------------------------------------------"
}

$reportContent | Out-File -FilePath $signatureReportFile
Write-Host "Check the new report: $signatureReportFile" -ForegroundColor Cyan