$scriptDirectory = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$skeletonReportFile = Join-Path -Path $scriptDirectory -ChildPath "..\2_Hex_Exploration\FFXI_Motion_Skeletons.txt"

if (-not (Test-Path $skeletonReportFile)) {
    Write-Host "Could not find $skeletonReportFile. Please run the Sort-Motions script first!" -ForegroundColor Red
    return
}

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host " Skeleton Auto-Test Generator" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "Enter the 2-character Skeleton ID you want to test (e.g., A0, A1, 00):"
$targetId = Read-Host "Skeleton ID"
$targetId = $targetId.Trim().ToUpper()

# Dynamically set the output file name to include the requested Skeleton ID
$outputTestFile = Join-Path -Path $scriptDirectory -ChildPath "AltanaViewer_SkeletonTest_Block_$targetId.csv"

$lines = Get-Content -Path $skeletonReportFile
$isTargetSection = $false
$filesFound = New-Object System.Collections.Generic.List[string]

foreach ($line in $lines) {
    if ($line -match "^Skeleton ID: \[([A-F0-9]{2})\]") {
        if ($matches[1] -eq $targetId) {
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
    Write-Host "No files found for Skeleton ID [$targetId]." -ForegroundColor Red
    return
}

Write-Host "Found $($filesFound.Count) files. Generating CSV Test Block..."

$csvContent = @(
    "",
    "@Auto-Generated Skeleton Tests ($targetId)"
)

foreach ($file in $filesFound) {
    $csvPath = $file -replace "^ROM/", ""
    $csvPath = $csvPath -replace "^ROM(\d+)/", "`$1/"
    $csvContent += "$csvPath,Test $csvPath"
}

$csvContent += ""
$csvContent | Out-File -FilePath $outputTestFile

Write-Host "Done! Your test block has been saved to: $outputTestFile" -ForegroundColor Yellow