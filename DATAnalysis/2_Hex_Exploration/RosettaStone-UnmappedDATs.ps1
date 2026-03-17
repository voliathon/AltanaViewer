Add-Type -AssemblyName System.Windows.Forms

$scriptDirectory = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$cleanListFile = Join-Path -Path $scriptDirectory -ChildPath "..\1_Core_Pipeline\AltanaViewer_CleanedData.txt"
$unmappedListFile = Join-Path -Path $scriptDirectory -ChildPath "..\1_Core_Pipeline\FFXI_Unmapped_Local_DATs.txt"
$rosettaReportFile = Join-Path -Path $scriptDirectory -ChildPath "FFXI_Rosetta_Signatures.txt"

# --- IGNORE LIST ---
# Add any 4-byte hex signatures here that you want pushed to the bottom of the report.
$ignoreList = @(
    "65 76 74 65", # evte (Event Triggers)
    "53 51 4C 45", # SQLE (Audio Files)
    "64 6D 73 67",  # dmsg (Dialogue Text)
	"6D 5F 79 6E", # m_yn
	"68 66 5F 30", # hf_0 (Motions Supposedly)
	"74 72 5F 30", # tr_0 (Motions Supposedly)
	"68 6D 5F 30", # hm_0 (Motions Supposedly)
	"65 6D 5F 30", # em_0 (Motions Supposedly)
	"67 6C 5F 30", # gl_0 (Motions Supposedly)
	"65 66 5F 30", # ef_0 (Motions Supposedly)
	"63 6C 65 61", # clea (No Beastmen)
	"6D 5F 62 65", # m_be (Objects was a nothing burger)
	"6D 5F 64 73" # m_ds (Nothing burger)
)

if (-not (Test-Path $cleanListFile) -or -not (Test-Path $unmappedListFile)) { Write-Host "Missing required text files in 1_Core_Pipeline!" -ForegroundColor Red; return }

# --- 1. Find FFXI Install Directory ---
$registryPaths = @("HKLM:\SOFTWARE\WOW6432Node\PlayOnlineUS\InstallFolder", "HKLM:\SOFTWARE\WOW6432Node\PlayOnlineEU\InstallFolder", "HKLM:\SOFTWARE\WOW6432Node\PlayOnline\InstallFolder")
$ffxiPath = $null
foreach ($path in $registryPaths) { if (Test-Path $path) { $ffxiPath = (Get-ItemProperty -Path $path -Name "0001" -ErrorAction SilentlyContinue)."0001"; if ($ffxiPath) { break } } }

if (-not $ffxiPath) {
    $ffxiBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $ffxiBrowser.Description = "Select your FINAL FANTASY XI folder:"
    if ($ffxiBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { $ffxiPath = $ffxiBrowser.SelectedPath } else { return }
}

# --- 2. Build Rosetta Stone ---
Write-Host "Building Rosetta Stone..."
$knownSignatures = @{}
$cleanLines = Get-Content -Path $cleanListFile | Where-Object { $_ -match "^ROM" }

foreach ($line in $cleanLines) {
    if ($line -match "^(ROM.*?)\s+\|\s+Found in:\s+(.*)$") {
        $localPath = Join-Path -Path $ffxiPath -ChildPath ($matches[1] -replace '/', '\')
        $localPath = "$localPath.DAT"
        if (Test-Path $localPath -PathType Leaf) {
            try {
                $bytes = Get-Content -Path $localPath -Encoding Byte -TotalCount 4 -ErrorAction Stop
                if ($bytes.Count -eq 4) {
                    $hexSig = [System.BitConverter]::ToString($bytes) -replace '-', ' '
                    if (-not $knownSignatures.ContainsKey($hexSig)) { $knownSignatures[$hexSig] = New-Object System.Collections.Generic.HashSet[string] }
                    foreach ($csv in ($matches[2] -split ', ')) { $null = $knownSignatures[$hexSig].Add($csv.Trim()) }
                }
            } catch { continue }
        }
    }
}

# --- 3. Inspect Unknowns ---
Write-Host "Inspecting unmapped files..."
$unmappedLines = Get-Content -Path $unmappedListFile | Where-Object { $_ -match "^ROM" }
$unknownGroups = @{}

foreach ($relativePath in $unmappedLines) {
    $localPath = Join-Path -Path $ffxiPath -ChildPath ($relativePath -replace '/', '\')
    $localPath = "$localPath.DAT"
    if (Test-Path $localPath -PathType Leaf) {
        try {
            $bytes = Get-Content -Path $localPath -Encoding Byte -TotalCount 4 -ErrorAction Stop
            $hexSig = if ($bytes.Count -eq 0) { "[EMPTY FILE]" } else { [System.BitConverter]::ToString($bytes) -replace '-', ' ' }
            if (-not $unknownGroups.ContainsKey($hexSig)) { $unknownGroups[$hexSig] = New-Object System.Collections.Generic.List[string] }
            $unknownGroups[$hexSig].Add($relativePath)
        } catch {
            if (-not $unknownGroups.ContainsKey("[UNREADABLE]")) { $unknownGroups["[UNREADABLE]"] = New-Object System.Collections.Generic.List[string] }
            $unknownGroups["[UNREADABLE]"].Add($relativePath)
        }
    }
}

# --- 4. Output Report ---
Write-Host "Formatting final report..."

$validGroups = @{}
$ignoredGroups = @{}
$totalValid = 0
$totalIgnored = 0

foreach ($group in $unknownGroups.GetEnumerator()) {
    $sig = $group.Key
    $count = $group.Value.Count
    if ($ignoreList -contains $sig) {
        $ignoredGroups[$sig] = $group.Value
        $totalIgnored += $count
    } else {
        $validGroups[$sig] = $group.Value
        $totalValid += $count
    }
}

$sortedValid = $validGroups.GetEnumerator() | Sort-Object { $_.Value.Count } -Descending
$sortedIgnored = $ignoredGroups.GetEnumerator() | Sort-Object { $_.Value.Count } -Descending

$reportContent = @(
    "=================================================",
    " FFXI Rosetta Stone - Signature Cross-Reference",
    " Total Files Inspected: $($unmappedLines.Count)",
    " Total Valid Unknowns:  $totalValid (Needs Testing)",
    " Total Ignored Files:   $totalIgnored",
    "=================================================",
    ""
)

$manualGuesses = @{ "6D 6F 74 5F" = "Motion / Animation files"; "65 76 74 65" = "Event / Cutscene triggers"; "53 51 4C 45" = "Square Enix Audio (SQLE format)"; "68 6D 5F 30" = "Hume Male 0 Models"; "64 6D 73 67" = "Dialogue/Text Data" }

# Print Valid Signatures
foreach ($group in $sortedValid) {
    $sig = $group.Key
    $count = $group.Value.Count
    
    $asciiMatch = ""
    if ($sig -match "^([0-9A-F]{2})\s([0-9A-F]{2})\s([0-9A-F]{2})\s([0-9A-F]{2})$") {
        try {
            $charArray = @([char][convert]::ToInt32($matches[1], 16), [char][convert]::ToInt32($matches[2], 16), [char][convert]::ToInt32($matches[3], 16), [char][convert]::ToInt32($matches[4], 16))
            $asciiMatch = " (ASCII: $(($charArray -join '') -replace '[^a-zA-Z0-9_]', '.'))"
        } catch {}
    }

    $matchString = if ($knownSignatures.ContainsKey($sig)) { $knownSignatures[$sig] -join ", " } else { "NONE (Completely Unknown Data)" }
    $guess = if ($manualGuesses.ContainsKey($sig)) { $manualGuesses[$sig] } elseif ($matchString -ne "NONE (Completely Unknown Data)") { "Likely associated with $matchString" } else { "Needs further inspection" }
    
    $reportContent += "Signature: [$sig]$asciiMatch - Found $count files`nMatches Altana Category: $matchString`nDeveloper Guess: $guess`nFiles:"
    foreach ($file in $group.Value) { $reportContent += $file }
    $reportContent += "-------------------------------------------------"
}

# Print Ignored Signatures
if ($totalIgnored -gt 0) {
    $reportContent += @(
        "",
        "=================================================",
        " === IGNORED SIGNATURES ===",
        " These files matched your ignore list and do not need testing.",
        "=================================================",
        ""
    )

    foreach ($group in $sortedIgnored) {
        $sig = $group.Key
        $count = $group.Value.Count
        
        $asciiMatch = ""
        if ($sig -match "^([0-9A-F]{2})\s([0-9A-F]{2})\s([0-9A-F]{2})\s([0-9A-F]{2})$") {
            try {
                $charArray = @([char][convert]::ToInt32($matches[1], 16), [char][convert]::ToInt32($matches[2], 16), [char][convert]::ToInt32($matches[3], 16), [char][convert]::ToInt32($matches[4], 16))
                $asciiMatch = " (ASCII: $(($charArray -join '') -replace '[^a-zA-Z0-9_]', '.'))"
            } catch {}
        }
        
        $reportContent += "IGNORED: [$sig]$asciiMatch - Found $count files`nFiles:"
        foreach ($file in $group.Value) { $reportContent += $file }
        $reportContent += "-------------------------------------------------"
    }
}

$reportContent | Out-File -FilePath $rosettaReportFile
Write-Host "Complete! Check the new report: $rosettaReportFile" -ForegroundColor Cyan