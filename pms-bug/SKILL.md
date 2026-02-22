---
name: pms-bug
description: "Create PMS bug reports on GitHub and sync to Google Sheets. Use when user says 'PMS Bug addition' or describes a bug in the Apni Pathshala PMS system. Creates GitHub issue, applies labels, assigns to roshanasingh4, updates PMS Task Tracker sheet and Team Daily Update sheet."
---

# PMS Bug Addition

Streamlined workflow for logging PMS bugs to GitHub and Google Sheets.

## Trigger
User message contains **"PMS Bug addition"** or describes a bug in the PMS system.

## Workflow

### 1. Collect Bug Information
Ask the user for (if not provided):
- **Title**: Brief bug summary
- **Description**: What's happening
- **Reproduction Steps**: How to reproduce
- **Expected Outcome**: What should happen
- **Priority**: P0 (Critical) / P1 (High) / P2 (Medium) / P3 (Low)
- **Task Type**: Issue (bug) / Feature (enhancement) / Testing

### 2. Create GitHub Issue
```bash
gh issue create --repo roshanasingh4/apni-pathshala-pms \
  --title "<title>" \
  --body "$(cat <<EOF
## Description
<description>

## Steps to Reproduce
1. <step 1>
2. <step 2>
3. <step 3>

## Expected Outcome
<expected outcome>

## Actual Outcome
<what actually happened>
EOF
)" \
  --label "bug,<priority>" \
  --assignee roshanasingh4
```

Capture the issue URL from output for the sheet.

### 3. Update PMS Task Tracker Sheet
**Sheet ID:** `1O07SzGzQa2FwpkBE7h2SUDWZlxsUpz8DxCpyxKjRi8U`
**Tab:** `Production`

#### Column Mapping (A-K)

| Col | Name | Value |
|-----|------|-------|
| A | Task ID | `PMS-TSKXXX` (increment from last entry) |
| B | Description | Issue title |
| C | Reporter | `Tara Singh Kharwad` |
| D | Date Submitted | `DD/MM/YYYY` (issue creation date) |
| E | Status | `New` |
| F | Task type | `Issue` (bug) / `Feature` (enhancement) / `Testing` |
| G | Priority | `Critical` (P0) / `High` (P1) / `Medium` (P2) / `Low` (P3) |
| H | Assigned To | `tarasinghrajput7261@gmail.com` |
| I | Resolution Notes | GitHub issue URL |
| J | Resolution Date | (empty until closed) |
| K | Took Help from Roshan | (leave empty - Tara fills manually) |

#### Label to Sheet Mapping

| GitHub Label | Task Type | Priority |
|--------------|-----------|----------|
| bug | Issue | - |
| enhancement | Feature | - |
| P0 | - | Critical |
| P1 | - | High |
| P2 | - | Medium |
| P3 | - | Low |

#### Get Next Task ID
```bash
gog sheets get 1O07SzGzQa2FwpkBE7h2SUDWZlxsUpz8DxCpyxKjRi8U "Production!A:A" --json | jq '.values | .[-1][0]'
```
Then increment the number.

#### Append to Sheet
```bash
gog sheets append 1O07SzGzQa2FwpkBE7h2SUDWZlxsUpz8DxCpyxKjRi8U "Production!A:K" \
  --values-json '[["PMS-TSK-XXX","<title>","Tara Singh Kharwad","DD/MM/YYYY","New","Issue","Low","tarasinghrajput7261@gmail.com","<github_url>","",""]]' \
  --insert INSERT_ROWS
```

### 4. Update Team Daily Update Sheet
**Sheet ID:** `1GgRgfVBrF-ReGPRmntT6Cm2BjiLzJ3JiBaC4lMfrMQs`

Find row with today's date, append to Column B with format:
```
- PMS - <title> - <github_url>
```

#### Format for Daily Tasks
Each day's tasks are in a single cell with headings and bullet points:
```
- PMS - Fixed login button issue - https://github.com/...
- PMS - Added export feature - https://github.com/...
```

#### Get Today's Row
```bash
# Find row with today's date
gog sheets get 1GgRgfVBrF-ReGPRmntT6Cm2BjiLzJ3JiBaC4lMfrMQs "Sheet1!A:B" --json
# Look for today's date (DD/MM/YYYY) in Column A
```

#### Update Cell
```bash
# Append to existing content in Column B
gog sheets update 1GgRgfVBrF-ReGPRmntT6Cm2BjiLzJ3JiBaC4lMfrMQs "Sheet1!B<row>" \
  --values-json '[["<existing_content>\n- PMS - <title> - <github_url>"]]'
```

## Priority Guide

| Priority | Label | When to Use |
|----------|-------|-------------|
| P0 | Critical | System down, data loss, security issue |
| P1 | High | Major feature broken, many users affected |
| P2 | Medium | Feature partially working, workaround exists |
| P3 | Low | Minor issue, cosmetic, low impact |

## Example Usage

User: "PMS Bug addition - Login page crashes on mobile"

Response:
1. Ask for details (steps, expected outcome, priority)
2. Create GitHub issue → get URL
3. Get next Task ID from sheet
4. Append to PMS Task Tracker sheet with all columns in the tab "Production"
5. Update Team Daily Update sheet with new entry

## Notes

- Reporter is ALWAYS "Tara Singh Kharwad"
- Assigned To is ALWAYS "tarasinghrajput7261@gmail.com"
- Resolution Notes = GitHub issue URL
- "Took Help from Roshan" is left empty (Tara fills manually)
- Date format: DD/MM/YYYY only
- Status starts as "New"
