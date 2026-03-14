Add-Type -AssemblyName System.Windows.Forms

$scriptDirectory = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$actionCsvFile = Join-Path -Path $scriptDirectory -ChildPath "Action.csv"
$outputReport = Join-Path -Path $scriptDirectory -ChildPath "FFXI_HumeM_Header_Analysis.txt"

if (-not (Test-Path $actionCsvFile)) {
    Write-Host "Could not find Action.csv. Please place it in the same folder as this script!" -ForegroundColor Red
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

# --- 2. Extract Verified HumeM Files ---
Write-Host "Scanning Action.csv for verified HumeM files..."
$lines = Get-Content -Path $actionCsvFile
$humeFiles = New-Object System.Collections.Generic.List[string]

foreach ($line in $lines) {
    # Look for files you explicitly labeled with "HumeM"
    if ($line -match "^([\d/]+),.*HumeM") {
        $humeFiles.Add($matches[1])
    }
}

if ($humeFiles.Count -eq 0) {
    Write-Host "Could not find any lines containing 'HumeM' in Action.csv." -ForegroundColor Red
    return
}

Write-Host "Found $($humeFiles.Count) Hume Male motion files to analyze."
Write-Host "Extracting deep headers..."

# --- 3. Deep Header Inspection ---
$reportContent = @(
    "=================================================",
    " FFXI Deep Header Analysis (First 32 Bytes)",
    " Target: Verified HumeM Motion Files",
    "=================================================",
    "",
    "Format: [Path] -> [Bytes 00-15] | [Bytes 16-31]",
    "-------------------------------------------------"
)

foreach ($relPath in $humeFiles) {
    # Standardize the path to include ROM1 if it's missing
    $fullRel = if ($relPath -match "^\d+/\d+$") { "ROM/$relPath" } else { $relPath }
    $fullRel = $fullRel -replace "^(\d+)/", "ROM`$1/"
    
    $localPath = Join-Path -Path $ffxiPath -ChildPath ($fullRel -replace '/', '\')
    $localPath = "$localPath.DAT"
    
    if (Test-Path $localPath -PathType Leaf) {
        try {
            # Grab the first 32 bytes
            $bytes = Get-Content -Path $localPath -Encoding Byte -TotalCount 32 -ErrorAction Stop
            
            # Format nicely: First 16 bytes, a pipe, then the next 16 bytes
            if ($bytes.Count -ge 32) {
                $hexPart1 = [System.BitConverter]::ToString($bytes[0..15]) -replace '-', ' '
                $hexPart2 = [System.BitConverter]::ToString($bytes[16..31]) -replace '-', ' '
                
                $paddedPath = $relPath.PadRight(12)
                $reportContent += "$paddedPath -> $hexPart1 | $hexPart2"
            }
        } catch {
            $reportContent += "$($relPath.PadRight(12)) -> [UNREADABLE]"
        }
    } else {
        $reportContent += "$($relPath.PadRight(12)) -> [FILE NOT FOUND]"
    }
}

$reportContent | Out-File -FilePath $outputReport

Write-Host "Deep Analysis Complete!" -ForegroundColor Green
Write-Host "Check the grid in: $outputReport" -ForegroundColor Cyan