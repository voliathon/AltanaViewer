Add-Type -AssemblyName System.Windows.Forms

# --- 1. Select AltanaViewer Folder ---
$folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
$folderBrowser.Description = "Please select your AltanaViewer folder:"
$folderBrowser.ShowNewFolderButton = $false

if ($folderBrowser.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
    Write-Host "AltanaViewer Folder selection cancelled. Stopping script." -ForegroundColor Yellow
    return
}
$altanaCsvFolder = $folderBrowser.SelectedPath
Write-Host "AltanaViewer folder selected: $altanaCsvFolder" -ForegroundColor Green

# --- 2. Initialize Paths and Dictionaries ---
$scriptDirectory = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$outputCleanFile = Join-Path -Path $scriptDirectory -ChildPath "AltanaViewer_CleanedData.txt"
$outputUncertainFile = Join-Path -Path $scriptDirectory -ChildPath "AltanaViewer_UncertainData.txt"
$outputUnmappedFile = Join-Path -Path $scriptDirectory -ChildPath "FFXI_Unmapped_Local_DATs.txt"

$masterDict = @{}   # Our Hash Table for ultra-fast lookups
$uncertainDict = @{} 

# --- 3. Extract, Sanitize, and Separate AltanaViewer Data ---
Write-Host "Parsing AltanaViewer CSVs to build the in-memory Hash Table..."
$allCsvFiles = Get-ChildItem -Path $altanaCsvFolder -Filter *.csv -Recurse

$csvFiles = $allCsvFiles | Where-Object {
    $name = $_.Name
    if ($name -match "(?i)^Music") { return $false }
    if ($name -match "(?i)^Motion") { return $false }
    if ($name -match "(?i)^floor\.csv$") { return $false }
    if ($name -match "(?i)index\.csv$") { return $false }
    return $true
}

foreach ($file in $csvFiles) {
    $relCsvPath = $file.FullName.Substring($altanaCsvFolder.Length).TrimStart('\').TrimStart('/')
    $lines = Get-Content -Path $file.FullName
    
    foreach ($line in $lines) {
        if ([string]::IsNullOrWhiteSpace($line) -or $line.Trim().StartsWith("@")) { continue }
        
        $rawData = $line.Split(',')[0].Trim()
        $subParts = $rawData -split ';'
        $currentPrefix = "" 
        
        foreach ($rawPart in $subParts) {
            $part = $rawPart.Trim().Replace('#', '')
            if ([string]::IsNullOrWhiteSpace($part)) { continue }
            
            if ($part -notmatch "/" -and $currentPrefix -ne "") { $part = $currentPrefix + $part }
            if ($part -match "^(.*)/") { $currentPrefix = $matches[1] + "/" }

            $isValidData = $false
            
            # FORMAT A: 3-Part Range
            if ($part -match "^(\d+)/(\d+)/(\d+)-(\d+)$") {
                $romPrefix = if ($matches[1] -eq "1") { "ROM" } else { "ROM$($matches[1])" }
                for ($i = [int]$matches[3]; $i -le [int]$matches[4]; $i++) {
                    $fullPath = "$romPrefix/$($matches[2])/$i"
                    if (-not $masterDict.ContainsKey($fullPath)) { $masterDict[$fullPath] = New-Object System.Collections.Generic.HashSet[string] }
                    $null = $masterDict[$fullPath].Add($relCsvPath)
                }
                $isValidData = $true
            }
            # FORMAT B: 2-Part Range
            elseif ($part -match "^(\d+)/(\d+)-(\d+)$") {
                for ($i = [int]$matches[2]; $i -le [int]$matches[3]; $i++) {
                    $fullPath = "ROM/$($matches[1])/$i"
                    if (-not $masterDict.ContainsKey($fullPath)) { $masterDict[$fullPath] = New-Object System.Collections.Generic.HashSet[string] }
                    $null = $masterDict[$fullPath].Add($relCsvPath)
                }
                $isValidData = $true
            }
            # FORMAT C: 3-Part Exact
            elseif ($part -match "^(\d+)/(\d+)/(\d+)$") {
                $romPrefix = if ($matches[1] -eq "1") { "ROM" } else { "ROM$($matches[1])" }
                $fullPath = "$romPrefix/$($matches[2])/$($matches[3])"
                if (-not $masterDict.ContainsKey($fullPath)) { $masterDict[$fullPath] = New-Object System.Collections.Generic.HashSet[string] }
                $null = $masterDict[$fullPath].Add($relCsvPath)
                $isValidData = $true
            }
            # FORMAT D: 2-Part Exact
            elseif ($part -match "^(\d+)/(\d+)$") {
                $fullPath = "ROM/$($matches[1])/$($matches[2])"
                if (-not $masterDict.ContainsKey($fullPath)) { $masterDict[$fullPath] = New-Object System.Collections.Generic.HashSet[string] }
                $null = $masterDict[$fullPath].Add($relCsvPath)
                $isValidData = $true
            }
            # FORMAT E: Cross-Folder Ranges
            elseif ($part -match "-.*\/") { $isValidData = $false }
            
            if (-not $isValidData) {
                if (-not $uncertainDict.ContainsKey($part)) { $uncertainDict[$part] = New-Object System.Collections.Generic.HashSet[string] }
                $null = $uncertainDict[$part].Add($relCsvPath)
            }
        }
    }
}

# --- 4. Format and Output AltanaViewer Logs ---
Write-Host "Saving AltanaViewer Clean and Uncertain Logs..."
$sortedCleanKeys = $masterDict.Keys | Sort-Object { [regex]::Replace($_, '\d+', { $args[0].Value.PadLeft(10, '0') }) }
$cleanContent = @("=== AltanaViewer Cleaned Master List ===", "Total Valid DATs Found: $($masterDict.Count)", "")
foreach ($key in $sortedCleanKeys) { $cleanContent += "$($key.PadRight(20)) | Found in: $($masterDict[$key] -join ', ')" }
$cleanContent | Out-File -FilePath $outputCleanFile

$sortedUncertainKeys = $uncertainDict.Keys | Sort-Object
$uncertainContent = @("=== AltanaViewer Uncertain / Unparsed List ===", "Total Issues Found: $($uncertainDict.Count)", "")
foreach ($key in $sortedUncertainKeys) { $uncertainContent += "$($key.PadRight(25)) | Found in: $($uncertainDict[$key] -join ', ')" }
$uncertainContent | Out-File -FilePath $outputUncertainFile


# --- 5. Find FFXI Install Directory ---
Write-Host "Hunting for FFXI Installation..." -ForegroundColor Cyan
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
    Write-Host "Could not find FFXI in registry. Please select your FFXI folder manually." -ForegroundColor Yellow
    $ffxiBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $ffxiBrowser.Description = "Select your FINAL FANTASY XI folder:"
    if ($ffxiBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $ffxiPath = $ffxiBrowser.SelectedPath
    } else {
        Write-Host "FFXI Folder selection cancelled. Stopping script." -ForegroundColor Red
        return
    }
}
Write-Host "FFXI Located at: $ffxiPath" -ForegroundColor Green

# --- 6. The Lightning-Fast Cross Check ---
Write-Host "Scanning local hard drive and cross-checking against the Hash Table (This will be very fast!)..."
# Using a List is heavily optimized for speed when adding thousands of records
$unmappedLocalFiles = New-Object System.Collections.Generic.List[string]

# Only grab folders that start with "ROM" inside the FFXI directory
$romFolders = Get-ChildItem -Path $ffxiPath -Directory -Filter "ROM*"

foreach ($folder in $romFolders) {
    $localDats = Get-ChildItem -Path $folder.FullName -Filter "*.dat" -Recurse
    
    foreach ($dat in $localDats) {
        # Convert "C:\...\FINAL FANTASY XI\ROM2\0\52.DAT" -> "ROM2/0/52"
        $relativePath = $dat.FullName.Substring($ffxiPath.Length).TrimStart('\')
        $hashKey = ($relativePath -replace '\\', '/') -replace '(?i)\.dat$', ''
        
        # O(1) Hash Table Lookup: Instantaneous check
        if (-not $masterDict.ContainsKey($hashKey)) {
            $unmappedLocalFiles.Add($hashKey)
        }
    }
}

# --- 7. Output the Unmapped Local Files ---
Write-Host "Sorting and saving unmapped local files..."
$sortedUnmapped = $unmappedLocalFiles | Sort-Object { [regex]::Replace($_, '\d+', { $args[0].Value.PadLeft(10, '0') }) }

$unmappedContent = @(
    "=================================================",
    " FFXI Local DATs Missing From AltanaViewer",
    " Total Unmapped Files Found: $($unmappedLocalFiles.Count)",
    "=================================================",
    ""
)
$unmappedContent += $sortedUnmapped

$unmappedContent | Out-File -FilePath $outputUnmappedFile

Write-Host "Complete!" -ForegroundColor Green
Write-Host "1. $outputCleanFile"
Write-Host "2. $outputUncertainFile"
Write-Host "3. $outputUnmappedFile (Review this one for the missing local files!)" -ForegroundColor Cyan