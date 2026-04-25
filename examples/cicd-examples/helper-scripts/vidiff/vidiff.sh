#!/bin/bash
set -e

# vidiff.sh — Generate VIDiff HTML reports for changed VIs in a PR.
#
# Usage: ./vidiff.sh <vi-file-1> [vi-file-2] ...
#
# Each argument is a workspace-relative path to a .vi file that changed in the PR.
# The script expects:
#   - The PR version of the VI at /workspace/<path>        (mounted from PR checkout)
#   - The main branch version at /workspace-base/<path>    (mounted from base checkout)
#   - Reports are written to /workspace/vidiff-reports/

LV_YEAR="${LV_YEAR:-2026}"
LABVIEW_PATH="/usr/local/natinst/LabVIEW-${LV_YEAR}-64/labviewprofull"
REPORT_DIR="/workspace/vidiff-reports"

if [ $# -eq 0 ]; then
  echo "Error: No VI files specified."
  echo "Usage: $0 <vi-file-1> [vi-file-2] ..."
  exit 1
fi

mkdir -p "$REPORT_DIR"

FAILED=0
TOTAL=0
SKIPPED=0

for VI_REL_PATH in "$@"; do
  TOTAL=$((TOTAL + 1))
  VI_NAME=$(basename "$VI_REL_PATH" .vi)

  VI_PR="/workspace/${VI_REL_PATH}"
  VI_BASE="/workspace-base/${VI_REL_PATH}"
  REPORT_PATH="${REPORT_DIR}/${VI_NAME}.html"

  echo "========================================================================"
  echo "VIDiff: ${VI_NAME}"
  echo "  PR version  : ${VI_PR}"
  echo "  Base version : ${VI_BASE}"
  echo "  Report       : ${REPORT_PATH}"
  echo "========================================================================"

  # Skip if the base version doesn't exist (new VI added in PR)
  if [ ! -f "$VI_BASE" ]; then
    echo "Skipping ${VI_NAME}: file does not exist on base branch (new VI)."
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  # Skip if the PR version doesn't exist (VI deleted in PR)
  if [ ! -f "$VI_PR" ]; then
    echo "Skipping ${VI_NAME}: file does not exist on PR branch (deleted VI)."
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  # Run LabVIEWCLI CreateComparisonReport
  if LabVIEWCLI -LogToConsole TRUE \
    -OperationName CreateComparisonReport \
    -VI1 "$VI_BASE" \
    -VI2 "$VI_PR" \
    -ReportType html \
    -ReportPath "$REPORT_PATH" \
    -LabVIEWPath "$LABVIEW_PATH" \
    -Headless; then
    echo "Report generated: ${REPORT_PATH}"
  else
    echo "Warning: VIDiff failed for ${VI_NAME} (exit code $?)."
    FAILED=$((FAILED + 1))
  fi

  echo ""
done

echo "========================================================================"
echo "VIDiff Summary: ${TOTAL} VIs processed, ${SKIPPED} skipped, ${FAILED} failed."
echo "========================================================================"

if [ "$FAILED" -gt 0 ]; then
  echo "Some VIDiff operations failed."
  exit 1
fi

echo "All VIDiff reports generated successfully."
exit 0
