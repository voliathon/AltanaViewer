Add-Type -AssemblyName System.Windows.Forms

$scriptDirectory = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$unmappedListFile = Join-Path -Path $scriptDirectory -ChildPath "..\1_Core_Pipeline\FFXI_Unmapped_Local_DATs.txt"
$outputFile = Join-Path -Path $scriptDirectory -ChildPath "XIData_Bulk_Mapped_Results.csv"

if (-not (Test-Path $unmappedListFile)) {
    Write-Host "Could not find FFXI_Unmapped_Local_DATs.txt in the 1_Core_Pipeline folder!" -ForegroundColor Red
    return
}

# --- 1. Select the Data Folder ---
$folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
$folderBrowser.Description = "Select the 'data' folder inside your xidata-v2-py folder:"
if ($folderBrowser.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
    return
}
$dataFolder = $folderBrowser.SelectedPath

# --- 2. Load Unmapped Hash Table ---
Write-Host "`nLoading 18,000 missing files into memory..." -ForegroundColor Yellow
$unmappedHash = @{}
$unmappedLines = Get-Content -Path $unmappedListFile | Where-Object { $_ -match "^ROM" }
foreach ($line in $unmappedLines) {
    $cleanLine = $line.Trim() -replace '\\', '/'
    $unmappedHash[$cleanLine] = $true
}

# --- 3. Process Every JSON File ---
Write-Host "Cross-referencing against all XIData databases. This might take a second..." -ForegroundColor Cyan
$jsonFiles = Get-ChildItem -Path $dataFolder -Filter "*.json"
$totalMatched = 0
$csvContent = @("=== XIDATA BULK RECOVERY LIST ===")

foreach ($file in $jsonFiles) {
    try {
        $jsonContent = Get-Content -Path $file.FullName -Raw | ConvertFrom-Json
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
        $localMatches = New-Object System.Collections.Generic.List[string]

        # Iterate through the JSON objects looking for standard DAT mappings
        foreach ($entry in $jsonContent) {
            $datPath = $null
            $name = $null

            # Josh uses different keys depending on the tool that generated the JSON
            if ($null -ne $entry.dat) { $datPath = $entry.dat }
            if ($null -ne $entry.name) { $name = $entry.name }
            elseif ($null -ne $entry.name_clean) { $name = $entry.name_clean }

            if ($datPath -and $name) {
                $cleanPath = $datPath -replace "(?i)\.dat$", ""
                $cleanPath = $cleanPath -replace '\\', '/'

                if ($unmappedHash.ContainsKey($cleanPath)) {
                    $csvPath = $cleanPath -replace "^(?i)ROM/", ""
                    $csvPath = $csvPath -replace "^(?i)ROM(\d+)/", "`$1/"
                    $localMatches.Add("$csvPath,$name")
                    $totalMatched++
                }
            }
        }

        # If we found matches in this JSON, create a UI category for them!
        if ($localMatches.Count -gt 0) {
            $csvContent += ""
            $csvContent += "@$baseName (XIData Recovered)"
            $csvContent += $localMatches
        }
    } catch {
        # Skip files that aren't formatted as arrays
    }
}

$csvContent | Out-File -FilePath $outputFile

Write-Host "`n=================================================" -ForegroundColor Green
Write-Host " Bulk Recovery Complete!" -ForegroundColor Green
Write-Host " Total Missing Files Identified: $totalMatched" -ForegroundColor White
Write-Host " Saved to: $outputFile" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Green