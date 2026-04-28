#!/bin/bash

# vidiff.sh — Generate VIDiff HTML reports for changed VIs in a PR.
#
# Usage: ./vidiff.sh <vi-file-1> [vi-file-2] ...
#
# Each argument is a workspace-relative path to a .vi file that changed in the PR.
# The script expects:
#   - The PR version of the VI at /workspace/<path>        (mounted from PR checkout)
#   - The main branch version at /workspace-base/<path>    (mounted from base checkout)
#   - Reports are written to /workspace/vidiff-reports/
#
# Modified VIs  -> CreateComparisonReport  (base vs head),  <name> (Modified).html
# Added VIs     -> PrintToSingleFileHtml   (head version),  <name> (Added).html
# Deleted VIs   -> PrintToSingleFileHtml   (base version),  <name> (Deleted).html

LV_YEAR="${LV_YEAR:-2026}"
LABVIEW_PATH="/usr/local/natinst/LabVIEW-${LV_YEAR}-64/labviewprofull"
REPORT_DIR="/workspace/vidiff-reports"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ $# -eq 0 ]; then
  echo "Error: No VI files specified."
  echo "Usage: $0 <vi-file-1> [vi-file-2] ..."
  exit 1
fi

mkdir -p "$REPORT_DIR"

# Returns 0 (true) if the file at the given path is a LabVIEW VI or LVCC file,
# identified by the magic bytes at offset 8 (bytes 9-12): LVIN or LVCC.
is_vi_file() {
  local path="$1"
  local magic
  [ -f "$path" ] || return 1
  magic=$(dd if="$path" bs=1 skip=8 count=4 2>/dev/null)
  [[ "$magic" == "LVIN" || "$magic" == "LVCC" ]]
}

FAILED=0
TOTAL=0
SKIPPED=0

for VI_REL_PATH in "$@"; do
  TOTAL=$((TOTAL + 1))
  VI_NAME=$(basename "$VI_REL_PATH" .vi)

  VI_PR="/workspace/${VI_REL_PATH}"
  VI_BASE="/workspace-base/${VI_REL_PATH}"

  PR_EXISTS=false
  BASE_EXISTS=false
  [ -f "$VI_PR" ] && PR_EXISTS=true
  [ -f "$VI_BASE" ] && BASE_EXISTS=true

  echo "========================================================================"
  echo "VIDiff: ${VI_NAME}"
  echo "  PR version  : ${VI_PR} ($( $PR_EXISTS && echo 'found' || echo 'not found' ))"
  echo "  Base version : ${VI_BASE} ($( $BASE_EXISTS && echo 'found' || echo 'not found' ))"
  echo "  Report       : (determined by change type)"
  echo "========================================================================"

  EXIT_CODE=0

  if $PR_EXISTS && $BASE_EXISTS; then
    # ---------- Modified: compare base vs head ----------
    REPORT_PATH="${REPORT_DIR}/${VI_NAME} (Modified).html"
    if ! is_vi_file "$VI_PR"; then
      echo "Skipping ${VI_NAME}: not a LabVIEW VI file (magic byte check)."
      SKIPPED=$((SKIPPED + 1))
      continue
    fi
    if ! is_vi_file "$VI_BASE"; then
      echo "Skipping ${VI_NAME}: base version is not a LabVIEW VI file."
      SKIPPED=$((SKIPPED + 1))
      continue
    fi

    echo "Running CreateComparisonReport (modified VI)..."
    if LabVIEWCLI -LogToConsole TRUE \
      -OperationName CreateComparisonReport \
      -VI1 "$VI_BASE" \
      -VI2 "$VI_PR" \
      -ReportType html \
      -ReportPath "$REPORT_PATH" \
      -LabVIEWPath "$LABVIEW_PATH" \
      -Headless; then
      EXIT_CODE=0
    else
      EXIT_CODE=$?
    fi

  elif $PR_EXISTS && ! $BASE_EXISTS; then
    # ---------- Added: print the new VI ----------
    REPORT_PATH="${REPORT_DIR}/${VI_NAME} (Added).html"
    if ! is_vi_file "$VI_PR"; then
      echo "Skipping ${VI_NAME}: not a LabVIEW VI file (magic byte check)."
      SKIPPED=$((SKIPPED + 1))
      continue
    fi

    echo "Running PrintToSingleFileHtml (added VI)..."
    if LabVIEWCLI \
      -OperationName PrintToSingleFileHtml \
      -LabVIEWPath "$LABVIEW_PATH" \
      -AdditionalOperationDirectory "$SCRIPT_DIR" \
      -LogToConsole TRUE \
      -VI "$VI_PR" \
      -OutputPath "$REPORT_PATH" \
      -o -c \
      -Headless; then
      EXIT_CODE=0
    else
      EXIT_CODE=$?
    fi

  elif ! $PR_EXISTS && $BASE_EXISTS; then
    # ---------- Deleted: print the old VI ----------
    REPORT_PATH="${REPORT_DIR}/${VI_NAME} (Deleted).html"
    if ! is_vi_file "$VI_BASE"; then
      echo "Skipping ${VI_NAME}: base version is not a LabVIEW VI file."
      SKIPPED=$((SKIPPED + 1))
      continue
    fi

    echo "Running PrintToSingleFileHtml (deleted VI)..."
    if LabVIEWCLI \
      -OperationName PrintToSingleFileHtml \
      -LabVIEWPath "$LABVIEW_PATH" \
      -AdditionalOperationDirectory "$SCRIPT_DIR" \
      -LogToConsole TRUE \
      -VI "$VI_BASE" \
      -OutputPath "$REPORT_PATH" \
      -o -c \
      -Headless; then
      EXIT_CODE=0
    else
      EXIT_CODE=$?
    fi

  else
    echo "Skipping ${VI_NAME}: file not found on either branch."
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  if [ $EXIT_CODE -ne 0 ]; then
    echo "Warning: VIDiff failed for ${VI_NAME} (exit code $EXIT_CODE)."
    FAILED=$((FAILED + 1))
  elif [ ! -f "$REPORT_PATH" ]; then
    echo "Warning: VIDiff exited 0 but report was not created: $REPORT_PATH"
    FAILED=$((FAILED + 1))
  else
    echo "Report generated: ${REPORT_PATH}"
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
