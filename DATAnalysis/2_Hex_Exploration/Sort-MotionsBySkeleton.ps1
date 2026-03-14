Add-Type -AssemblyName System.Windows.Forms

$scriptDirectory = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$unmappedListFile = Join-Path -Path $scriptDirectory -ChildPath "FFXI_Unmapped_Local_DATs.txt"
$skeletonReportFile = Join-Path -Path $scriptDirectory -ChildPath "FFXI_Motion_Skeletons.txt"

if (-not (Test-Path $unmappedListFile)) {
    Write-Host "Could not find $unmappedListFile. Please run the Find-Unmapped script first!" -ForegroundColor Red
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

# --- 2. Scan for mot_ files and extract Skeleton IDs ---
Write-Host "Scanning unmapped DATs for Motion files and extracting Skeleton IDs..."
$unmappedLines = Get-Content -Path $unmappedListFile | Where-Object { $_ -match "^ROM" }
$skeletonGroups = @{}
$motCount = 0

foreach ($relPath in $unmappedLines) {
    $localPath = Join-Path -Path $ffxiPath -ChildPath ($relPath -replace '/', '\')
    $localPath = "$localPath.DAT"
    
    if (Test-Path $localPath -PathType Leaf) {
        try {
            $bytes = Get-Content -Path $localPath -Encoding Byte -TotalCount 20 -ErrorAction Stop
            
            # Check if it's a mot_ file (6D 6F 74 5F)
            if ($bytes.Count -ge 20 -and $bytes[0] -eq 0x6D -and $bytes[1] -eq 0x6F -and $bytes[2] -eq 0x74 -and $bytes[3] -eq 0x5F) {
                $motCount++
                
                # Grab Byte 19 (The Skeleton ID)
                $skeletonId = [System.BitConverter]::ToString($bytes[19..19])
                
                if (-not $skeletonGroups.ContainsKey($skeletonId)) {
                    $skeletonGroups[$skeletonId] = New-Object System.Collections.Generic.List[string]
                }
                $skeletonGroups[$skeletonId].Add($relPath)
            }
        } catch {}
    }
}

# --- 3. Output Report ---
Write-Host "Found $motCount Motion files. Formatting Skeleton Report..."
$sortedSkeletons = $skeletonGroups.GetEnumerator() | Sort-Object { $_.Value.Count } -Descending

$reportContent = @(
    "=================================================",
    " FFXI Motion Files - Skeleton ID Profiler",
    " Total Motion Files Sorted: $motCount",
    "=================================================",
    ""
)

foreach ($group in $sortedSkeletons) {
    $skelId = $group.Key
    $count = $group.Value.Count
    
    # Label the one we already know!
    $label = if ($skelId -eq "A0") { "Hume Male" } elseif ($skelId -eq "00") { "Empty / Reset Dummy" } else { "Unknown Race/Monster" }
    
    $reportContent += "Skeleton ID: [$skelId] - Found $count files ($label)"
    $reportContent += "Files:"
    foreach ($file in $group.Value) {
        $reportContent += $file
    }
    $reportContent += "-------------------------------------------------"
}

$reportContent | Out-File -FilePath $skeletonReportFile

Write-Host "Complete!" -ForegroundColor Green
Write-Host "Check the new report: $skeletonReportFile" -ForegroundColor Cyan