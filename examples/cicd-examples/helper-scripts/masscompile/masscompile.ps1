param(
    [string]$WorkspaceRoot = "C:\workspace"
)

$LabVIEWPath   = "C:\Program Files\National Instruments\LabVIEW 2026\LabVIEW.exe"
$MassCompileDir = Join-Path $WorkspaceRoot "examples\cicd-examples\Test-VIs"

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
