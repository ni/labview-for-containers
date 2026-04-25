#!/bin/bash
set -e

LV_YEAR="${LV_YEAR:-2026}"
LABVIEW_PATH="/usr/local/natinst/LabVIEW-${LV_YEAR}-64/labviewprofull"
MASSCOMPILE_DIR='/workspace/examples/cicd-examples/Test-VIs'

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
