param(
    [string]$WorkspaceRoot = "C:\workspace"
)

$ConfigFile    = Join-Path $WorkspaceRoot "examples\integration-into-cicd\Test-VIs\viaPassCase.viancfg"
$LabVIEWPath   = "C:\Program Files\National Instruments\LabVIEW 2026\LabVIEW.exe"
$ReportPath    = "C:\ContainerExamples\Results.txt"
$MassCompileDir = Join-Path $WorkspaceRoot "examples\integration-into-cicd\Test-VIs"

# Verify that the configuration file exists.
if (-not (Test-Path -Path $ConfigFile)) {
    Write-Host "Error: Configuration file not found at $ConfigFile, exiting..." -ForegroundColor Red
    exit 1
}

# Ensure the report directory exists.
$reportDir = Split-Path -Path $ReportPath -Parent
if (-not (Test-Path -Path $reportDir)) {
    New-Item -ItemType Directory -Path $reportDir -Force | Out-Null
}

Write-Host "Running LabVIEWCLI MassCompile with the following parameters:" -ForegroundColor Cyan
Write-Host "DirectoryToCompile: $MassCompileDir"

& LabVIEWCLI `
    -LogToConsole TRUE `
    -OperationName MassCompile `
    -DirectoryToCompile "$MassCompileDir" `
    -LabVIEWPath "$LabVIEWPath" `
    -Headless

Write-Host ""; Write-Host "Done running MassCompile operation" -ForegroundColor Green
Write-Host "########################################################################################"
Write-Host ""

Write-Host "Running LabVIEWCLI VI Analyzer with the following parameters:" -ForegroundColor Cyan
Write-Host "ConfigPath: $ConfigFile"
Write-Host "ReportPath: $ReportPath"
Write-Host ""

& LabVIEWCLI `
    -LogToConsole TRUE `
    -OperationName RunVIAnalyzer `
    -ConfigPath "$ConfigFile" `
    -ReportPath "$ReportPath" `
    -LabVIEWPath "$LabVIEWPath" `
    -Headless

Write-Host "Done running VI Analyzer tests" -ForegroundColor Green
Write-Host "Printing Results..."
Write-Host ""
Write-Host "########################################################################################"

if (Test-Path -Path $ReportPath) {
    Get-Content -Path $ReportPath | Write-Host
} else {
    Write-Host "Warning: Report file not found at $ReportPath" -ForegroundColor Yellow
}

# Extract the number of failed tests from the report file.
$failedCount = 0
if (Test-Path -Path $ReportPath) {
    $failedLine = Select-String -Path $ReportPath -Pattern '^Failed Tests\s*([0-9]+)$' | Select-Object -First 1
    if ($failedLine) {
        $match = [regex]::Match($failedLine.Line, '^Failed Tests\s*([0-9]+)$')
        if ($match.Success) {
            [void][int]::TryParse($match.Groups[1].Value, [ref]$failedCount)
        }
    }
}

Write-Host "Number of failed tests: $failedCount"

if ($failedCount -gt 0) {
    Write-Host "Some tests failed. Exiting with error." -ForegroundColor Red
    Write-Host "########################################################################################"
    exit 1
} else {
    Write-Host "All tests passed." -ForegroundColor Green
    Write-Host "########################################################################################"
    exit 0
}
