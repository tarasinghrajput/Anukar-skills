#!/usr/bin/env bash
set -euo pipefail

# append-issue.sh — Append a new issue row within the Production sheet table.
# Usage: ./append-issue.sh -p <PROJECT> -d <DESCRIPTION> -t <TYPE> -r <PRIORITY> -u <URL> [-D <DATE>]
#
# Arguments:
#   -p | --project      Project name (PMS | Apna Dashboard | Prerna | Empowered Indian)
#   -d | --description  Issue title / short description
#   -t | --type         Task type (Issue | Feature)
#   -r | --priority     Priority (Low | Medium | High | Critical)
#   -u | --url          GitHub issue URL
#   -D | --date         Date in DD/MM/YYYY (default: today IST)
#   -h | --help         Show this help

SPREADSHEET_ID="1O07SzGzQa2FwpkBE7h2SUDWZlxsUpz8DxCpyxKjRi8U"
SHEET_TITLE="Production"
SHEET_ID="2067862113"
ASSIGNEE_NAME="Tara Singh Kharwad"
ASSIGNED_TO="tarasinghrajput7261@gmail.com"
STATUS="New"

# ── Defaults ────────────────────────────────────────────────────────────────
DATE=$(TZ='Asia/Kolkata' date +%d/%m/%Y)

# ── Parse arguments ─────────────────────────────────────────────────────────
PROJECT=""
DESCRIPTION=""
TASK_TYPE=""
PRIORITY=""
ISSUE_URL=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -p|--project)      PROJECT="$2";      shift 2 ;;
        -d|--description)  DESCRIPTION="$2";   shift 2 ;;
        -t|--type)         TASK_TYPE="$2";     shift 2 ;;
        -r|--priority)     PRIORITY="$2";      shift 2 ;;
        -u|--url)          ISSUE_URL="$2";     shift 2 ;;
        -D|--date)         DATE="$2";          shift 2 ;;
        -h|--help)         sed -n '2,12p' "$0"; exit 0 ;;
        *) echo "Unknown argument: $1"; exit 1 ;;
    esac
done

# Validate required args
if [[ -z "$PROJECT" || -z "$DESCRIPTION" || -z "$TASK_TYPE" || -z "$PRIORITY" || -z "$ISSUE_URL" ]]; then
    echo "Error: missing required arguments" >&2
    sed -n '3,12p' "$0" >&2
    exit 1
fi

# ── Helpers ─────────────────────────────────────────────────────────────────
strip_keyring() {
    # gws prints "Using keyring backend: keyring" on stderr; we already get
    # JSON on stdout, but if both are mixed (as sometimes happens via pipes),
    # strip the first line when it starts with "Using".
    sed '/^Using keyring/d'
}

die() {
    echo "ERROR: $*" >&2
    exit 1
}

# ── Step 1: Read column A, compute next Sr. no ──────────────────────────────
echo "→ Reading Sr. no..."

COL_A=$(gws sheets +read \
    --spreadsheet "$SPREADSHEET_ID" \
    --range "${SHEET_TITLE}!A:A" 2>/dev/null)

NEXT_SR=$(echo "$COL_A" | python3 -c "
import json, sys
data = json.load(sys.stdin)
vals = data.get('values', [])
nums = []
for v in vals:
    if v and v[0] and v[0].startswith('PMS-TSK-'):
        parts = v[0].split('-')
        if len(parts) >= 3 and parts[2].isdigit():
            nums.append(int(parts[2]))
if nums:
    n = max(nums) + 1
    print(f'PMS-TSK-{n:03d}')
else:
    print('PMS-TSK-001')
") || die "Failed to parse Sr. no"

echo "  Sr. no: $NEXT_SR"

# ── Step 2: Get table endRowIndex ───────────────────────────────────────────
echo "→ Reading table boundary..."

META=$(gws sheets spreadsheets get \
    --params "{\"spreadsheetId\": \"$SPREADSHEET_ID\", \"includeGridData\": false, \"ranges\": [\"$SHEET_TITLE\"]}" \
    2>/dev/null)

END_ROW=$(echo "$META" | python3 -c "
import json, sys
data = json.load(sys.stdin)
for s in data.get('sheets', []):
    for t in s.get('tables', []):
        print(t['range']['endRowIndex'])
        break
    break
") || die "Failed to read table boundary"

echo "  Table endRowIndex: $END_ROW"

# ── Step 3: Insert dimension at table boundary ──────────────────────────────
echo "→ Expanding table..."

gws sheets spreadsheets batchUpdate \
    --params "{\"spreadsheetId\": \"$SPREADSHEET_ID\"}" \
    --json "{
      \"requests\": [{
        \"insertDimension\": {
          \"range\": {
            \"sheetId\": $SHEET_ID,
            \"dimension\": \"ROWS\",
            \"startIndex\": $END_ROW,
            \"endIndex\": $((END_ROW + 1))
          },
          \"inheritFromBefore\": true
        }
      }]
    }" 2>/dev/null | strip_keyring > /dev/null || die "insertDimension failed"

NEXT_ROW=$((END_ROW + 1))
echo "  New row: $NEXT_ROW"

# ── Step 4: Write row data ──────────────────────────────────────────────────
echo "→ Writing row data..."

gws sheets spreadsheets values update \
    --params "{\"spreadsheetId\": \"$SPREADSHEET_ID\", \"range\": \"${SHEET_TITLE}!A${NEXT_ROW}:M${NEXT_ROW}\", \"valueInputOption\": \"USER_ENTERED\"}" \
    --json "{\"values\": [[\"$NEXT_SR\",\"$DESCRIPTION\",\"$ASSIGNEE_NAME\",\"$PROJECT\",\"$DATE\",\"$STATUS\",\"$TASK_TYPE\",\"$PRIORITY\",\"$ASSIGNED_TO\",\"$ISSUE_URL\",\"\",\"\",\"\"]]}" \
    2>/dev/null | strip_keyring > /dev/null || die "values.update failed"

# ── Step 5: Verify ──────────────────────────────────────────────────────────
echo "→ Verifying..."

VERIFIED=$(gws sheets +read \
    --spreadsheet "$SPREADSHEET_ID" \
    --range "${SHEET_TITLE}!A${NEXT_ROW}:J${NEXT_ROW}" \
    2>/dev/null)

echo "$VERIFIED" | python3 -c "
import json, sys
data = json.load(sys.stdin)
vals = data.get('values', [[]])[0]
expected = ['$NEXT_SR', '$DESCRIPTION', '$ASSIGNEE_NAME', '$PROJECT', '$DATE', '$STATUS', '$TASK_TYPE', '$PRIORITY', '$ASSIGNED_TO', '$ISSUE_URL']
ok = True
for i, (got, exp) in enumerate(zip(vals, expected)):
    if got != exp:
        print(f'  MISMATCH col {i}: got \"{got}\", expected \"{exp}\"')
        ok = False
if ok:
    print('  All columns match ✓')
else:
    sys.exit(1)
" || die "Verification failed — row data does not match"

# ── Done ────────────────────────────────────────────────────────────────────
echo ""
echo "✓ Row $NEXT_ROW appended successfully (${SHEET_TITLE})"
echo "  Sr. no:    $NEXT_SR"
echo "  Project:   $PROJECT"
echo "  Task type: $TASK_TYPE"
echo "  Priority:  $PRIORITY"
echo "  URL:       $ISSUE_URL"
