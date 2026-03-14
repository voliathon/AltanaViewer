# Generate-TestCSV.ps1

$scriptDirectory = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$rosettaReportFile = Join-Path -Path $scriptDirectory -ChildPath "..\2_Hex_Exploration\FFXI_Rosetta_Signatures.txt"
$outputTestFile = Join-Path -Path $scriptDirectory -ChildPath "AltanaViewer_AutoTest_Block.csv"

if (-not (Test-Path $rosettaReportFile)) {
    Write-Host "Could not find $rosettaReportFile. Please run the Rosetta Stone script first!" -ForegroundColor Red
    return
}

# Ask the user which signature they want to generate tests for
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host " AltanaViewer Auto-Test Generator" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "Enter the EXACT 4-byte signature from your Rosetta report you want to test."
Write-Host "(Example: 6D 6F 74 5F for Motions, or 68 6D 5F 30 for Hume Models)"
$targetSig = Read-Host "Signature"
$targetSig = $targetSig.Trim().ToUpper()

Write-Host "`nScanning Rosetta Stone for signature [$targetSig]..."

$lines = Get-Content -Path $rosettaReportFile
$isTargetSection = $false
$filesFound = New-Object System.Collections.Generic.List[string]

# Parse the text file to extract the files under that specific signature
foreach ($line in $lines) {
    if ($line -match "^Signature: \[([A-F0-9\s]{11})\]") {
        if ($matches[1] -eq $targetSig) {
            $isTargetSection = $true
            continue
        } else {
            $isTargetSection = $false
        }
    }
    
    if ($isTargetSection -and $line -match "^ROM") {
        $filesFound.Add($line.Trim())
    }
}

if ($filesFound.Count -eq 0) {
    Write-Host "No files found for signature [$targetSig]. Did you type it correctly?" -ForegroundColor Red
    return
}

Write-Host "Found $($filesFound.Count) unknown files for this signature!" -ForegroundColor Green
Write-Host "Generating CSV Test Block..."

# Build the CSV formatting
$csvContent = @(
    "",
    "@Auto-Generated Tests ($targetSig)"
)

foreach ($file in $filesFound) {
    # Strip the "ROM" prefix for the CSV format if it's ROM 1, otherwise keep the number
    # AltanaViewer CSVs usually format ROM/0/14 as just 0/14, and ROM2/0/52 as 2/0/52
    $csvPath = $file -replace "^ROM/", ""
    $csvPath = $csvPath -replace "^ROM(\d+)/", "`$1/"
    
    # Format: 68/76, Test 68/76
    $csvContent += "$csvPath,Test $csvPath"
}

$csvContent += ""

$csvContent | Out-File -FilePath $outputTestFile

Write-Host "Done! Your test block has been saved to: $outputTestFile" -ForegroundColor Yellow
Write-Host "You can now open that file, copy the block, and paste it at the bottom of Action.csv (for motions) or a model CSV to instantly test them in the viewer!" -ForegroundColor Cyan