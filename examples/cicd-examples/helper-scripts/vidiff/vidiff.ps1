param(
    [string]$WorkspaceRoot = "C:\workspace",
    [string]$WorkspaceBaseRoot = "C:\workspace-base",
    [Parameter(Mandatory=$true)]
    [string[]]$VIFiles
)

# vidiff.ps1 — Generate VIDiff HTML reports for changed VIs in a PR.
#
# Usage: .\vidiff.ps1 -WorkspaceRoot "C:\workspace" -WorkspaceBaseRoot "C:\workspace-base" -VIFiles "path\to\file1.vi","path\to\file2.vi"
#
# Each entry in VIFiles is a workspace-relative path to a .vi file that changed in the PR.
# The script expects:
#   - The PR version of the VI at $WorkspaceRoot\<path>
#   - The main branch version at $WorkspaceBaseRoot\<path>
#   - Reports are written to $WorkspaceRoot\vidiff-reports\

$LabVIEWPath = "C:\Program Files\National Instruments\LabVIEW 2026\LabVIEW.exe"
$ReportDir = Join-Path $WorkspaceRoot "vidiff-reports"

if (-not (Test-Path -Path $ReportDir)) {
    New-Item -ItemType Directory -Path $ReportDir -Force | Out-Null
}

$Failed = 0
$Total = 0
$Skipped = 0

foreach ($VIRelPath in $VIFiles) {
    $Total++
    $VIName = [System.IO.Path]::GetFileNameWithoutExtension($VIRelPath)

    $VIPR = Join-Path $WorkspaceRoot $VIRelPath
    $VIBase = Join-Path $WorkspaceBaseRoot $VIRelPath
    $ReportPath = Join-Path $ReportDir "$VIName.html"

    Write-Host "========================================================================"
    Write-Host "VIDiff: $VIName"
    Write-Host "  PR version  : $VIPR"
    Write-Host "  Base version : $VIBase"
    Write-Host "  Report       : $ReportPath"
    Write-Host "========================================================================"

    # Skip if the base version doesn't exist (new VI added in PR)
    if (-not (Test-Path -Path $VIBase)) {
        Write-Host "Skipping ${VIName}: file does not exist on base branch (new VI)." -ForegroundColor Yellow
        $Skipped++
        continue
    }

    # Skip if the PR version doesn't exist (VI deleted in PR)
    if (-not (Test-Path -Path $VIPR)) {
        Write-Host "Skipping ${VIName}: file does not exist on PR branch (deleted VI)." -ForegroundColor Yellow
        $Skipped++
        continue
    }

    # Run LabVIEWCLI CreateComparisonReport
    & LabVIEWCLI `
        -LogToConsole TRUE `
        -OperationName CreateComparisonReport `
        -VI1 "$VIBase" `
        -VI2 "$VIPR" `
        -ReportType html `
        -ReportPath "$ReportPath" `
        -LabVIEWPath "$LabVIEWPath" `
        -Headless

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Report generated: $ReportPath" -ForegroundColor Green
    } else {
        Write-Host "Warning: VIDiff failed for $VIName (exit code $LASTEXITCODE)." -ForegroundColor Red
        $Failed++
    }

    Write-Host ""
}

Write-Host "========================================================================"
Write-Host "VIDiff Summary: $Total VIs processed, $Skipped skipped, $Failed failed."
Write-Host "========================================================================"

if ($Failed -gt 0) {
    Write-Host "Some VIDiff operations failed." -ForegroundColor Red
    exit 1
}

Write-Host "All VIDiff reports generated successfully." -ForegroundColor Green
exit 0
