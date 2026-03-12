# Run-FFXIDatPipeline.ps1

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host " Starting FFXI DAT Exploration Pipeline" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

$scriptDirectory = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }

# Step 1: Clean data and find unmapped files
Write-Host "`n[1/3] Executing Find-UnmappedDATs.ps1..." -ForegroundColor Yellow
$script1 = Join-Path -Path $scriptDirectory -ChildPath "Find-UnmappedDATs.ps1"
if (Test-Path $script1) { & $script1 } else { Write-Host "Missing $script1. Aborting." -ForegroundColor Red; return }

# Step 2: Generate the basic hex signature report
Write-Host "`n[2/3] Executing SignatureReport-UnmappedDATs.ps1..." -ForegroundColor Yellow
$script2 = Join-Path -Path $scriptDirectory -ChildPath "SignatureReport-UnmappedDATs.ps1"
if (Test-Path $script2) { & $script2 } else { Write-Host "Missing $script2. Aborting." -ForegroundColor Red; return }

# Step 3: Cross-reference and build the Rosetta Stone
Write-Host "`n[3/3] Executing RosettaStone-UnmappedDATs.ps1..." -ForegroundColor Yellow
$script3 = Join-Path -Path $scriptDirectory -ChildPath "RosettaStone-UnmappedDATs.ps1"
if (Test-Path $script3) { & $script3 } else { Write-Host "Missing $script3. Aborting." -ForegroundColor Red; return }

Write-Host "`n=================================================" -ForegroundColor Green
Write-Host " Pipeline Execution Complete!" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green