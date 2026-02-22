---
name: daily-update
description: "Update the Team Daily Update sheet with completed tasks. Use when user says 'Daily update' or 'Update daily sheet' or 'Log my tasks'. Finds today's row in the current month's tab and updates Column B (Tara's tasks)."
---

# Daily Task Update

Update the Team Daily Update sheet with completed tasks for Tara.

## Trigger
User message contains:
- **"Daily update"** → Update today's tasks
- **"Update daily sheet"** → Update today's tasks
- **"Log my tasks"** → Update today's tasks
- **"Add task to daily"** → Append a task to today's entry

## Sheet Details
- **Sheet ID:** `1GgRgfVBrF-ReGPRmntT6Cm2BjiLzJ3JiBaC4lMfrMQs`
- **Tara's Column:** B
- **Tab Pattern:** `{Month} {Year} Daily Updates` (e.g., "February 2026 Daily Updates")
- **Date Format:** `D-M-YYYY` (e.g., "22-2-2026")

## Task Format Structure
Tasks are organized by category with bullet points:
```
Website
 - Task 1
 - Task 2
Software
 - Task 1
 - Task 2
Connect With:
 - Person 1
Working Hours : X Hrs
Freelance Wala
 - Task 1
Unwanted/Additional Tasks
 - Task 1
```

## Workflow

### 1. Determine Current Month Tab
Get current date and format the tab name:
```
{Full Month Name} {Year} Daily Updates
```
Example: "February 2026 Daily Updates"

### 2. Find Today's Row
```bash
gog sheets get 1GgRgfVBrF-ReGPRmntT6Cm2BjiLzJ3JiBaC4lMfrMQs "{TabName}!A:A" --json
```
Look for today's date in format `D-M-YYYY` (e.g., "22-2-2026")

### 3. Get Current Content
If row exists, get current content from Column B:
```bash
gog sheets get 1GgRgfVBrF-ReGPRmntT6Cm2BjiLzJ3JiBaC4lMfrMQs "{TabName}!B{row}" --json
```

### 4. Update or Append Tasks

#### Option A: Full Update (replace entire content)
Use when user provides complete task list:
```bash
gog sheets update 1GgRgfVBrF-ReGPRmntT6Cm2BjiLzJ3JiBaC4lMfrMQs "{TabName}!B{row}" \
  --values-json '[["<full_task_content>"]]'
```

#### Option B: Append Task (add to existing)
Use when user wants to add a single task to existing content:
```bash
# Get existing content, then append new task
existing_content="<current_content>\n<new_task>"
gog sheets update 1GgRgfVBrF-ReGPRmntT6Cm2BjiLzJ3JiBaC4lMfrMQs "{TabName}!B{row}" \
  --values-json '[["<existing_content>\n<new_task>"]]'
```

## Task Categories

| Category | Description | Prefix in entry |
|----------|-------------|-----------------|
| Website | Website-related tasks | `Website` |
| Software | PMS, development, software tasks | `Software` |
| Connect With | People to connect with | `Connect With:` |
| Working Hours | Total hours worked | `Working Hours : X Hrs` |
| Freelance Wala | Tasks related to FW | `Freelance Wala` |
| Unwanted/Additional | Non-planned tasks | `Unwanted/Additional Tasks` |

## Example Usage

### Example 1: Log full day's tasks
User: "Daily update: Website - Updated homepage, Fixed bug. Software - Tested PMS, Created issue #45. 8 hours."

Response:
1. Determine tab: "February 2026 Daily Updates"
2. Find row for today (22-2-2026)
3. Format tasks:
```
Website
 - Updated homepage
 - Fixed bug
Software
 - Tested PMS
 - Created issue #45
Working Hours : 8 Hrs
```
4. Update cell B{row}

### Example 2: Append a task
User: "Add task to daily: Connected with Pranav about monthly report"

Response:
1. Get today's current content from Column B
2. Append under appropriate category or at end:
```
Connect With:
 - Pranav about monthly report
```
3. Update the cell

### Example 3: Quick log
User: "Log my tasks"

Response:
1. Ask: "What tasks did you complete today? Categories: Website, Software, Connect With, Freelance Wala, Other"
2. Format response and update sheet

## Notes

- Date format in sheet: `D-M-YYYY` (single digit day/month without leading zeros)
- If row for today doesn't exist, append a new row with today's date in Column A
- Always confirm before overwriting existing content
- Preserve the structured format with category headers
- Sundays show "Sunday" in all cells - don't update those

## Quick Commands

### Get today's current tasks
```bash
# First get all dates to find row
gog sheets get 1GgRgfVBrF-ReGPRmntT6Cm2BjiLzJ3JiBaC4lMfrMQs "February 2026 Daily Updates!A:B" --json
```

### Update today's tasks
```bash
gog sheets update 1GgRgfVBrF-ReGPRmntT6Cm2BjiLzJ3JiBaC4lMfrMQs "February 2026 Daily Updates!B{row}" \
  --values-json '[["Website\n - Task 1\n - Task 2\nSoftware\n - Task 1\n\nWorking Hours : 8 Hrs"]]'
```
