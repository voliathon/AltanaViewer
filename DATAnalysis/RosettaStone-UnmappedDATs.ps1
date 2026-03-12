Add-Type -AssemblyName System.Windows.Forms

$scriptDirectory = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$cleanListFile = Join-Path -Path $scriptDirectory -ChildPath "AltanaViewer_CleanedData.txt"
$unmappedListFile = Join-Path -Path $scriptDirectory -ChildPath "FFXI_Unmapped_Local_DATs.txt"
$rosettaReportFile = Join-Path -Path $scriptDirectory -ChildPath "FFXI_Rosetta_Signatures.txt"

if (-not (Test-Path $cleanListFile) -or -not (Test-Path $unmappedListFile)) {
    Write-Host "Missing required text files. Ensure CleanedData and Unmapped_Local_DATs are in this folder!" -ForegroundColor Red
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
    } else { return }
}

# --- 2. Build the Rosetta Stone (Known Signatures) ---
Write-Host "Building Rosetta Stone from known AltanaViewer files... (This takes a moment)"
$knownSignatures = @{}
$cleanLines = Get-Content -Path $cleanListFile | Where-Object { $_ -match "^ROM" }

foreach ($line in $cleanLines) {
    if ($line -match "^(ROM.*?)\s+\|\s+Found in:\s+(.*)$") {
        $relPath = $matches[1]
        $csvNames = $matches[2]
        
        $localPath = Join-Path -Path $ffxiPath -ChildPath ($relPath -replace '/', '\')
        $localPath = "$localPath.DAT"
        
        if (Test-Path $localPath -PathType Leaf) {
            try {
                $bytes = Get-Content -Path $localPath -Encoding Byte -TotalCount 4 -ErrorAction Stop
                if ($bytes.Count -eq 4) {
                    $hexSig = [System.BitConverter]::ToString($bytes) -replace '-', ' '
                    
                    if (-not $knownSignatures.ContainsKey($hexSig)) {
                        $knownSignatures[$hexSig] = New-Object System.Collections.Generic.HashSet[string]
                    }
                    
                    foreach ($csv in ($csvNames -split ', ')) {
                        $null = $knownSignatures[$hexSig].Add($csv.Trim())
                    }
                }
            } catch { continue }
        }
    }
}

# --- 3. Inspect Unknown Files ---
Write-Host "Inspecting the unmapped files and cross-referencing..."
$unmappedLines = Get-Content -Path $unmappedListFile | Where-Object { $_ -match "^ROM" }
$unknownGroups = @{}

foreach ($relativePath in $unmappedLines) {
    $localPath = Join-Path -Path $ffxiPath -ChildPath ($relativePath -replace '/', '\')
    $localPath = "$localPath.DAT"
    
    if (Test-Path $localPath -PathType Leaf) {
        try {
            $bytes = Get-Content -Path $localPath -Encoding Byte -TotalCount 4 -ErrorAction Stop
            $hexSig = if ($bytes.Count -eq 0) { "[EMPTY FILE]" } else { [System.BitConverter]::ToString($bytes) -replace '-', ' ' }
            
            if (-not $unknownGroups.ContainsKey($hexSig)) {
                $unknownGroups[$hexSig] = New-Object System.Collections.Generic.List[string]
            }
            $unknownGroups[$hexSig].Add($relativePath)
        } catch {
            if (-not $unknownGroups.ContainsKey("[UNREADABLE]")) {
                $unknownGroups["[UNREADABLE]"] = New-Object System.Collections.Generic.List[string]
            }
            $unknownGroups["[UNREADABLE]"].Add($relativePath)
        }
    }
}

# --- 4. Output the Rosetta Report ---
Write-Host "Formatting final report..."
$sortedUnknowns = $unknownGroups.GetEnumerator() | Sort-Object { $_.Value.Count } -Descending

$reportContent = @(
    "=================================================",
    " FFXI Rosetta Stone - Signature Cross-Reference",
    " Total Unknown Files Inspected: $($unmappedLines.Count)",
    "=================================================",
    ""
)

# Hardcoded manual translations based on previous data mining
$manualGuesses = @{
    "6D 6F 74 5F" = "Motion / Animation files"
    "65 76 74 65" = "Event / Cutscene triggers"
    "53 51 4C 45" = "Square Enix Audio (SQLE format)"
    "68 6D 5F 30" = "Hume Male 0 Models"
}

foreach ($group in $sortedUnknowns) {
    $sig = $group.Key
    $count = $group.Value.Count
    
    $asciiMatch = ""
    if ($sig -match "^([0-9A-F]{2})\s([0-9A-F]{2})\s([0-9A-F]{2})\s([0-9A-F]{2})$") {
        try {
            $charArray = @(
                [char][convert]::ToInt32($matches[1], 16),
                [char][convert]::ToInt32($matches[2], 16),
                [char][convert]::ToInt32($matches[3], 16),
                [char][convert]::ToInt32($matches[4], 16)
            )
            $asciiWord = ($charArray -join '') -replace '[^a-zA-Z0-9_]', '.'
            $asciiMatch = " (ASCII: $asciiWord)"
        } catch {}
    }

    $matchString = "NONE (Completely Unknown Data)"
    if ($knownSignatures.ContainsKey($sig)) {
        $matchString = $knownSignatures[$sig] -join ", "
    }
    
    # Determine the best guess for this signature
    $guess = "Needs further inspection"
    if ($manualGuesses.ContainsKey($sig)) {
        $guess = $manualGuesses[$sig]
    } elseif ($matchString -ne "NONE (Completely Unknown Data)") {
        $guess = "Likely associated with $matchString"
    }
    
    $reportContent += "Signature: [$sig]$asciiMatch - Found $count files"
    $reportContent += "Matches Altana Category: $matchString"
    $reportContent += "Developer Guess: $guess"
    $reportContent += "Files:"
    
    # Print every single file on its own row
    foreach ($file in $group.Value) {
        $reportContent += $file
    }
    
    $reportContent += "-------------------------------------------------"
}

$reportContent | Out-File -FilePath $rosettaReportFile

Write-Host "Complete!" -ForegroundColor Green
Write-Host "Check the new report: $rosettaReportFile" -ForegroundColor Cyan