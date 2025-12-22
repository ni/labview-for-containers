#!/bin/bash
CONFIG_FILE='/workspace/examples/integration-into-cicd/Test-VIs/viaPassCase.viancfg'
LV_YEAR="${LV_YEAR:-2026}"
LABVIEW_PATH="/usr/local/natinst/LabVIEW-${LV_YEAR}-64/labviewprofull"
REPORT_PATH='/usr/local/natinst/ContainerExamples/Results.txt'
MASSCOMPILE_DIR='/workspace/examples/integration-into-cicd/Test-VIs'

# Verify that the configuration file exists.
if [ ! -f "$CONFIG_FILE" ]; then
  echo "Error: Configuration file not found at $CONFIG_FILE, exiting...!"
  exit 1
fi


echo "Running LabVIEWCLI MassCompile with following parameters:"
echo "DirectorytoCompile: $MASSCOMPILE_DIR"

LabVIEWCLI -LogToConsole TRUE \
-OperationName MassCompile \
-DirectoryToCompile $MASSCOMPILE_DIR \
-LabVIEWPath $LABVIEW_PATH \
-Headless

echo " "
echo "Done Running Masscompile Operation"
echo "########################################################################################"
echo " "

echo "Running LabVIEWCLI VIAnalyzer with the following parameters:"
echo "ConfigPath: $CONFIG_FILE"
echo "ReportPath: $REPORT_PATH"
echo " "

# Run the LabVIEWCLI VIA command.
LabVIEWCLI -LogToConsole TRUE \
-OperationName RunVIAnalyzer \
-ConfigPath $CONFIG_FILE \
-ReportPath $REPORT_PATH \
-LabVIEWPath $LABVIEW_PATH \
-Headless

echo "Done running of VI Analyzer Tests"
echo "Printing Results..."
echo " "
echo "########################################################################################"
cat "$REPORT_PATH"

# 1) Extract the number from the report file, anchor to “Failed Tests”
FAILED_COUNT=$(
  sed -n 's/^Failed Tests[[:space:]]*\([0-9]\+\)$/\1/p' "$REPORT_PATH"
)

# 2) Default to zero if it didn’t match
: "${FAILED_COUNT:=0}"

# 3) Sanity-check numeric
if ! [[ "$FAILED_COUNT" =~ ^[0-9]+$ ]]; then
  echo "Warning: parsed FAILED_COUNT ('$FAILED_COUNT') is not numeric, defaulting to 0" >&2
  FAILED_COUNT=0
fi

echo "Number of failed tests: $FAILED_COUNT"

# 4) Exit based on count
if (( FAILED_COUNT > 0 )); then
  echo "✖ Some tests failed. Exiting with error."
  echo "########################################################################################"
  exit 1
else
  echo "✔ All tests passed."
  echo "########################################################################################"
  exit 0
fi
