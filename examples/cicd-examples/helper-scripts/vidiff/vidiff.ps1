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
#
# Modified VIs  -> CreateComparisonReport  (base vs head),  <name> (Modified).html
# Added VIs     -> PrintToSingleFileHtml   (head version),  <name> (Added).html
# Deleted VIs   -> PrintToSingleFileHtml   (base version),  <name> (Deleted).html

$LabVIEWPath = "C:\Program Files\National Instruments\LabVIEW 2026\LabVIEW.exe"
$AdditionalOpDir = Join-Path $PSScriptRoot "."
$ReportDir = Join-Path $WorkspaceRoot "vidiff-reports"

if (-not (Test-Path -Path $ReportDir)) {
    New-Item -ItemType Directory -Path $ReportDir -Force | Out-Null
}

# Returns $true if the file at the given path is a LabVIEW VI or LVCC file,
# identified by the magic bytes at offset 8 (bytes 9-12): LVIN or LVCC.
function IsViFile {
    param([string]$Path)
    if (-not (Test-Path $Path)) { return $false }
    $bytes = [System.IO.File]::ReadAllBytes($Path)
    if ($bytes.Length -lt 12) { return $false }
    $magic = [System.Text.Encoding]::ASCII.GetString($bytes, 8, 4)
    return ($magic -eq 'LVIN' -or $magic -eq 'LVCC')
}

$Failed = 0
$Total = 0
$Skipped = 0

foreach ($VIRelPath in $VIFiles) {
    $Total++
    $VIName = [System.IO.Path]::GetFileNameWithoutExtension($VIRelPath)

    $VIPR = Join-Path $WorkspaceRoot $VIRelPath
    $VIBase = Join-Path $WorkspaceBaseRoot $VIRelPath

    $PRExists = Test-Path -Path $VIPR
    $BaseExists = Test-Path -Path $VIBase

    Write-Host "========================================================================"
    Write-Host "VIDiff: $VIName"
    Write-Host "  PR version  : $VIPR $(if ($PRExists) { '(found)' } else { '(not found)' })"
    Write-Host "  Base version : $VIBase $(if ($BaseExists) { '(found)' } else { '(not found)' })"
    Write-Host "  Report       : (determined by change type)"
    Write-Host "========================================================================"

    if ($PRExists -and $BaseExists) {
        # ---------- Modified: compare base vs head ----------
        $ReportPath = Join-Path $ReportDir "$VIName (Modified).html"
        if (-not (IsViFile $VIPR)) {
            Write-Host "Skipping ${VIName}: not a LabVIEW VI file (magic byte check)." -ForegroundColor Yellow
            $Skipped++
            continue
        }
        if (-not (IsViFile $VIBase)) {
            Write-Host "Skipping ${VIName}: base version is not a LabVIEW VI file." -ForegroundColor Yellow
            $Skipped++
            continue
        }

        Write-Host "Running CreateComparisonReport (modified VI)..."
        & LabVIEWCLI `
            -LogToConsole TRUE `
            -OperationName CreateComparisonReport `
            -VI1 "$VIBase" `
            -VI2 "$VIPR" `
            -ReportType html `
            -ReportPath "$ReportPath" `
            -LabVIEWPath "$LabVIEWPath" `
            -Headless

    } elseif ($PRExists -and -not $BaseExists) {
        # ---------- Added: print the new VI ----------
        $ReportPath = Join-Path $ReportDir "$VIName (Added).html"
        if (-not (IsViFile $VIPR)) {
            Write-Host "Skipping ${VIName}: not a LabVIEW VI file (magic byte check)." -ForegroundColor Yellow
            $Skipped++
            continue
        }

        Write-Host "Running PrintToSingleFileHtml (added VI)..."
        & LabVIEWCLI `
            -OperationName PrintToSingleFileHtml `
            -LabVIEWPath "$LabVIEWPath" `
            -AdditionalOperationDirectory "$AdditionalOpDir" `
            -LogToConsole TRUE `
            -VI "$VIPR" `
            -OutputPath "$ReportPath" `
            -o -c `
            -Headless

    } elseif (-not $PRExists -and $BaseExists) {
        # ---------- Deleted: print the old VI ----------
        $ReportPath = Join-Path $ReportDir "$VIName (Deleted).html"
        if (-not (IsViFile $VIBase)) {
            Write-Host "Skipping ${VIName}: base version is not a LabVIEW VI file." -ForegroundColor Yellow
            $Skipped++
            continue
        }

        Write-Host "Running PrintToSingleFileHtml (deleted VI)..."
        & LabVIEWCLI `
            -OperationName PrintToSingleFileHtml `
            -LabVIEWPath "$LabVIEWPath" `
            -AdditionalOperationDirectory "$AdditionalOpDir" `
            -LogToConsole TRUE `
            -VI "$VIBase" `
            -OutputPath "$ReportPath" `
            -o -c `
            -Headless

    } else {
        Write-Host "Skipping ${VIName}: file not found on either branch." -ForegroundColor Yellow
        $Skipped++
        continue
    }

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Warning: VIDiff failed for $VIName (exit code $LASTEXITCODE)." -ForegroundColor Red
        $Failed++
    } elseif (-not (Test-Path $ReportPath)) {
        Write-Host "Warning: VIDiff exited 0 but report was not created: $ReportPath" -ForegroundColor Red
        $Failed++
    } else {
        Write-Host "Report generated: $ReportPath" -ForegroundColor Green
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
