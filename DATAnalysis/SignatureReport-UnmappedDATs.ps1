Add-Type -AssemblyName System.Windows.Forms

$scriptDirectory = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$unmappedListFile = Join-Path -Path $scriptDirectory -ChildPath "FFXI_Unmapped_Local_DATs.txt"
$signatureReportFile = Join-Path -Path $scriptDirectory -ChildPath "FFXI_Unknown_Signatures.txt"

if (-not (Test-Path $unmappedListFile)) {
    Write-Host "Could not find $unmappedListFile. Please make sure it is in the same folder as this script!" -ForegroundColor Red
    return
}

# --- 1. Find FFXI Install Directory ---
$registryPaths = @(
    "HKLM:\SOFTWARE\WOW6432Node\PlayOnlineUS\InstallFolder",
    "HKLM:\SOFTWARE\WOW6432Node\PlayOnlineEU\InstallFolder",
    "HKLM:\SOFTWARE\WOW6432Node\PlayOnline\InstallFolder"
)

$ffxiPath = $null
foreach ($path in $registryPaths) {
    if (Test-Path $path) {
        $ffxiPath = (Get-ItemProperty -Path $path -Name "0001" -ErrorAction SilentlyContinue)."0001"
        if ($ffxiPath) { break }
    }
}

if (-not $ffxiPath) {
    $ffxiBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $ffxiBrowser.Description = "Select your FINAL FANTASY XI folder:"
    if ($ffxiBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $ffxiPath = $ffxiBrowser.SelectedPath
    } else {
        return
    }
}

# --- 2. Read the Unmapped List ---
Write-Host "Reading the unmapped DAT list..."
$unmappedLines = Get-Content -Path $unmappedListFile | Where-Object { $_ -match "^ROM" }

# --- 3. The Hex Inspector ---
Write-Host "Inspecting the headers of $($unmappedLines.Count) files... (This may take a minute or two)"

# Dictionary to group files by their Hex Signature
$signatureGroups = @{}

foreach ($relativePath in $unmappedLines) {
    # Convert "ROM2/0/52" back into "C:\...\FINAL FANTASY XI\ROM2\0\52.DAT"
    $localPath = Join-Path -Path $ffxiPath -ChildPath ($relativePath -replace '/', '\')
    $localPath = "$localPath.DAT"
    
    if (Test-Path $localPath -PathType Leaf) {
        try {
            # Use -Encoding Byte for Windows PowerShell 5.1 compatibility
            $bytes = Get-Content -Path $localPath -Encoding Byte -TotalCount 4 -ErrorAction Stop
            
            if ($bytes.Count -eq 0) {
                $hexSig = "[EMPTY FILE]"
            } else {
                # Convert bytes to a readable hex string (e.g., "52 49 46 46")
                $hexSig = [System.BitConverter]::ToString($bytes) -replace '-', ' '
            }
            
            # Group them in the dictionary
            if (-not $signatureGroups.ContainsKey($hexSig)) {
                $signatureGroups[$hexSig] = New-Object System.Collections.Generic.List[string]
            }
            $signatureGroups[$hexSig].Add($relativePath)
            
        } catch {
            $hexSig = "[UNREADABLE]"
            if (-not $signatureGroups.ContainsKey($hexSig)) {
                $signatureGroups[$hexSig] = New-Object System.Collections.Generic.List[string]
            }
            $signatureGroups[$hexSig].Add($relativePath)
        }
    }
}

# --- 4. Format and Output the Report ---
Write-Host "Building Signature Report..."

# Sort by the most common signatures first
$sortedSignatures = $signatureGroups.GetEnumerator() | Sort-Object { $_.Value.Count } -Descending

$reportContent = @(
    "=================================================",
    " FFXI Unmapped Files - Hex Signature Profiler",
    " Total Files Inspected: $($unmappedLines.Count)",
    "=================================================",
    ""
)

foreach ($group in $sortedSignatures) {
    $sig = $group.Key
    $count = $group.Value.Count
    
    # Grab the first 5 files as an example
    $examples = $group.Value | Select-Object -First 5
    $exampleString = $examples -join ", "
    if ($count -gt 5) { $exampleString += "... (and $($count - 5) more)" }
    
    $reportContent += "Signature: [$sig] - Found $count files"
    $reportContent += "Examples:  $exampleString"
    $reportContent += "-------------------------------------------------"
}

$reportContent | Out-File -FilePath $signatureReportFile

Write-Host "Inspection Complete!" -ForegroundColor Green
Write-Host "Check the new report: $signatureReportFile" -ForegroundColor Cyan