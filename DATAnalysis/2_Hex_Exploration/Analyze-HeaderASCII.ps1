Add-Type -AssemblyName System.Windows.Forms

$scriptDirectory = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$outputReport = Join-Path -Path $scriptDirectory -ChildPath "FFXI_ASCII_Dump.txt"

# --- 1. Find FFXI Install Directory ---
$registryPaths = @("HKLM:\SOFTWARE\WOW6432Node\PlayOnlineUS\InstallFolder", "HKLM:\SOFTWARE\WOW6432Node\PlayOnlineEU\InstallFolder", "HKLM:\SOFTWARE\WOW6432Node\PlayOnline\InstallFolder")
$ffxiPath = $null
foreach ($path in $registryPaths) { if (Test-Path $path) { $ffxiPath = (Get-ItemProperty -Path $path -Name "0001" -ErrorAction SilentlyContinue)."0001"; if ($ffxiPath) { break } } }

if (-not $ffxiPath) {
    $ffxiBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $ffxiBrowser.Description = "Select your FINAL FANTASY XI folder:"
    if ($ffxiBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { $ffxiPath = $ffxiBrowser.SelectedPath } else { return }
}

# --- 2. Select the CSV to Scan ---
$fileBrowser = New-Object System.Windows.Forms.OpenFileDialog
$fileBrowser.Title = "Select a CSV file to scan (e.g., WS.csv or an Unmapped Test Block)"
$fileBrowser.Filter = "CSV Files (*.csv)|*.csv|Text Files (*.txt)|*.txt"

if ($fileBrowser.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) { return }
$targetFile = $fileBrowser.FileName
Write-Host "`nScanning $(Split-Path $targetFile -Leaf)..." -ForegroundColor Cyan

# --- 3. Read and Extract ASCII ---
$lines = Get-Content $targetFile
$reportContent = @(
    "=================================================",
    " FFXI ASCII Header Dump",
    " Source: $(Split-Path $targetFile -Leaf)",
    "=================================================",
    ""
)

$count = 0

foreach ($line in $lines) {
    # Skip empty lines or category headers
    if ([string]::IsNullOrWhiteSpace($line) -or $line.StartsWith("@")) { continue }

    $datPath = $null
    $datName = "Unknown Name"
    
    # Check if line has a comma (e.g., "206/106,Ascetic's Fury" or "ROM/206/106,Test Name")
    if ($line -match "^(ROM/\d+/\d+|\d+/\d+),(.*)$") {
        $rawPath = $matches[1].Trim()
        $datName = $matches[2].Trim()
        $datPath = if ($rawPath -match "^ROM/") { $rawPath } else { "ROM/$rawPath" }
    } 
    # Check if line is just a raw path (e.g., "206/106" or "ROM/206/106")
    elseif ($line -match "^(ROM/\d+/\d+|\d+/\d+)$") {
        $rawPath = $matches[1].Trim()
        $datPath = if ($rawPath -match "^ROM/") { $rawPath } else { "ROM/$rawPath" }
    }

    if ($datPath) {
        $localPath = Join-Path -Path $ffxiPath -ChildPath ($datPath -replace '/', '\')
        $localPath = "$localPath.DAT"

        if (Test-Path $localPath -PathType Leaf) {
            try {
                # Grab the first 128 bytes of the file
                $bytes = Get-Content -Path $localPath -Encoding Byte -TotalCount 128 -ErrorAction Stop
                
                # Convert to ASCII (Replacing unreadable binary code with a dot '.')
                $asciiString = ""
                foreach ($b in $bytes) {
                    if ($b -ge 32 -and $b -le 126) {
                        $asciiString += [char]$b
                    } else {
                        $asciiString += "."
                    }
                }
                
                $reportContent += "File: $datPath ($datName)"
                $reportContent += "ASCII: $asciiString"
                $reportContent += "--------------------------------------------------"
                $count++
            } catch { }
        }
    }
}

$reportContent | Out-File -FilePath $outputReport
Write-Host "Successfully dumped ASCII for $count files!" -ForegroundColor Green
Write-Host "Check the report: $outputReport" -ForegroundColor Yellow