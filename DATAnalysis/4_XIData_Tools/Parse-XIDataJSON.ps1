Add-Type -AssemblyName System.Windows.Forms

$scriptDirectory = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$unmappedListFile = Join-Path -Path $scriptDirectory -ChildPath "..\1_Core_Pipeline\FFXI_Unmapped_Local_DATs.txt"
$outputFile = Join-Path -Path $scriptDirectory -ChildPath "XIData_Mapped_Results.csv"
$logFile = Join-Path -Path $scriptDirectory -ChildPath "Parse-XIDataJSON_Debug.log"

# --- Start Logger ---
"=================================================" | Out-File -FilePath $logFile
" XIData JSON Parser Debug Log" | Out-File -FilePath $logFile -Append
" Time: $(Get-Date)" | Out-File -FilePath $logFile -Append
"=================================================" | Out-File -FilePath $logFile -Append

if (-not (Test-Path $unmappedListFile)) {
    $msg = "Could not find FFXI_Unmapped_Local_DATs.txt in the 1_Core_Pipeline folder!"
    Write-Host $msg -ForegroundColor Red
    $msg | Out-File -FilePath $logFile -Append
    return
}

# --- 1. Select the XIData JSON File ---
$fileBrowser = New-Object System.Windows.Forms.OpenFileDialog
$fileBrowser.Title = "Select a JSON file from xidata-v2-py/data/"
$fileBrowser.Filter = "JSON Files (*.json)|*.json"

if ($fileBrowser.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
    "Selection cancelled by user." | Out-File -FilePath $logFile -Append
    return
}
$jsonPath = $fileBrowser.FileName
Write-Host "Selected: $(Split-Path $jsonPath -Leaf)" -ForegroundColor Cyan
"Selected JSON File: $jsonPath" | Out-File -FilePath $logFile -Append

# --- 2. Load Unmapped DATs into a Hash Table ---
$unmappedHash = @{}
$unmappedLines = Get-Content -Path $unmappedListFile | Where-Object { $_ -match "^ROM" }

foreach ($line in $unmappedLines) {
    # Trim spaces and normalize backslashes to forward slashes just in case
    $cleanLine = $line.Trim() -replace '\\', '/'
    $unmappedHash[$cleanLine] = $true
}

"Loaded $($unmappedHash.Count) files into the Unmapped Hash Table." | Out-File -FilePath $logFile -Append
"`n[Sample Keys in Hash Table]:" | Out-File -FilePath $logFile -Append
$unmappedHash.Keys | Select-Object -First 5 | Out-File -FilePath $logFile -Append

# --- 3. Parse the JSON ---
Write-Host "Parsing JSON and cross-referencing..."
"`n[Beginning JSON Parse...]" | Out-File -FilePath $logFile -Append
$jsonContent = Get-Content -Path $jsonPath -Raw | ConvertFrom-Json

$baseName = [System.IO.Path]::GetFileNameWithoutExtension($jsonPath)

$csvContent = @(
    "",
    "@$baseName (Imported from XIData)"
)

$matchCount = 0
$loopCount = 0

foreach ($entry in $jsonContent) {
    $loopCount++
    
    # We only want to intensely debug the first 5 entries so the log isn't massive
    if ($loopCount -le 5) {
        "`n--- JSON Entry $loopCount ---" | Out-File -FilePath $logFile -Append
        "Raw Data: $($entry | ConvertTo-Json -Compress)" | Out-File -FilePath $logFile -Append
    }

    if ($null -ne $entry.name -and $null -ne $entry.dat) {
        # Strip .dat extension and normalize slashes
        $cleanPath = $entry.dat -replace "(?i)\.dat$", ""
        $cleanPath = $cleanPath -replace '\\', '/'
        
        if ($loopCount -le 5) {
            "Searching Hash Table for Key: [$cleanPath]" | Out-File -FilePath $logFile -Append
        }
        
        if ($unmappedHash.ContainsKey($cleanPath)) {
            $matchCount++
            $csvPath = $cleanPath -replace "^(?i)ROM/", ""
            $csvPath = $csvPath -replace "^(?i)ROM(\d+)/", "`$1/"
            $csvContent += "$csvPath,$($entry.name)"
            
            if ($loopCount -le 5) {
                "Result: MATCHED!" | Out-File -FilePath $logFile -Append
            }
        } else {
            if ($loopCount -le 5) {
                "Result: NOT FOUND in Hash Table." | Out-File -FilePath $logFile -Append
            }
        }
    } else {
        if ($loopCount -le 5) {
            "Result: SKIPPED (Missing 'name' or 'dat' property in JSON)" | Out-File -FilePath $logFile -Append
        }
    }
}

"`n[Finished]" | Out-File -FilePath $logFile -Append
"Total JSON items processed: $loopCount" | Out-File -FilePath $logFile -Append
"Total missing files successfully mapped: $matchCount" | Out-File -FilePath $logFile -Append

if ($matchCount -eq 0) {
    Write-Host "`nNo missing DATs matched the contents of this JSON." -ForegroundColor Yellow
    Write-Host "Check Parse-XIDataJSON_Debug.log to see why!" -ForegroundColor Red
    return
}

$csvContent += ""
$csvContent | Out-File -FilePath $outputFile

Write-Host "`nSuccessfully mapped $matchCount missing files with exact names!" -ForegroundColor Green
Write-Host "Results saved to: $outputFile" -ForegroundColor Cyan