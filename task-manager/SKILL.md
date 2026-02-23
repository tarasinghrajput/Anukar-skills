---
name: task-manager
description: "Manage Tara's daily tasks from planning to completion. Use when user says 'plan my day', 'morning tasks', 'task done', 'update daily sheet', or 'EOD summary'. Reads weekly targets from Tech tab, helps plan the day, updates Team Daily Update sheet, and provides EOD comparison."
---

# Task Manager

Manage Tara's daily task workflow from planning to completion tracking.

## Trigger
- **"Plan my day"** → Morning task planning
- **"Morning tasks"** → Show today's tasks from weekly sheet
- **"Task done: [task]"** → Mark task as completed
- **"Update daily sheet"** → Update Team Daily Update sheet
- **"EOD summary"** → End of day comparison (planned vs completed)

---

## Sheet & Task References

| Resource | ID | Purpose |
|----------|-------|---------|
| **Weekly Targets Sheet** | `1to3web3WdMHlGWGnu5BieMX2QZ0AN9J0iTgLRZac5T4` | Tech tab - source of truth |
| **Team Daily Update Sheet** | `1GgRgfVBrF-ReGPRmntT6Cm2BjiLzJ3JiBaC4lMfrMQs` | {Month} {Year} Daily Updates |
| **Google Tasks List** | `YXdrWnhDNkYzWldMc2plaQ` | AP Weekly Tasks |

---

## Workflow

### Phase 1: Morning Planning (10:00 AM)

#### Step 1: Read Weekly Targets

Fetch Tara's tasks from the Weekly Target Sheet:

```bash
# Get current week number
CURRENT_WEEK=$(date +%V)  # ISO week number

# Fetch Tech tab data
gog sheets get 1to3web3WdMHlGWGnu5BieMX2QZ0AN9J0iTgLRZac5T4 "Tech!A:K" --json | \
python3 -c "
import sys, json
import datetime

data = json.load(sys.stdin)
values = data.get('values', [])

# Find current month
months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC']
current_month = months[datetime.datetime.now().month - 1]

# Filter for Tara's tasks
tara_tasks = []
for row in values[1:]:  # Skip header
    if len(row) >= 8:
        assigned_to = row[3].upper() if len(row) > 3 else ''
        team = row[4].upper() if len(row) > 4 else ''
        status = row[7].upper() if len(row) > 7 else ''
        
        if 'TARA' in assigned_to and status in ['IN PROGRESS', 'NOT STARTED', 'NEW', '']:
            task = {
                'week': row[0] if len(row) > 0 else '',
                'month': row[1] if len(row) > 1 else '',
                'task': row[2] if len(row) > 2 else '',
                'team': team,
                'priority': row[6] if len(row) > 6 else '',
                'status': status,
                'blockers': row[8] if len(row) > 8 else ''
            }
            tara_tasks.append(task)

# Separate by team
software_tasks = [t for t in tara_tasks if 'SOFTWARE' in t['team']]
website_tasks = [t for t in tara_tasks if 'WEBSITE' in t['team']]

print('SOFTWARE_TASKS:', len(software_tasks))
for t in software_tasks[:5]:
    print(f\"  - {t['task'][:60]}...\")

print('WEBSITE_TASKS:', len(website_tasks))
for t in website_tasks[:5]:
    print(f\"  - {t['task'][:60]}...\")
"
```

#### Step 2: Display Tasks for Planning

Show Tara his tasks organized by team and priority:

```
📋 Good Morning Tara! Here are your tasks for today:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔹 SOFTWARE TEAM (5 tasks)

P0 (Critical):
  1. PMS Bug - Weekly report status not updating
  2. Curriculum designer - Add YouTube API integration

P1 (High):
  3. Test 15 issues from GitHub
  4. Update PMS tracker sheet

P2 (Medium):
  5. Research clawdbot integration

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🌐 WEBSITE TEAM (3 tasks)

P1 (High):
  1. Update homepage content
  2. Fix mobile responsiveness on POD page

P2 (Medium):
  3. Review annual report page

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 What tasks do you want to work on today?
Reply with the task numbers (e.g., "1, 2, 4, 7")
```

#### Step 3: Generate WhatsApp Format

After Tara selects tasks, format them for WhatsApp:

```
Work Start 10:00 AM: 

*SOFTWARE*: 
1. PMS Bug - Weekly report status not updating
2. Test 15 issues from GitHub
3. Update PMS tracker sheet

*WEBSITE*: 
1. Update homepage content
2. Review annual report page
```

---

### Phase 2: Throughout the Day

#### Track Completed Tasks

When Tara says **"task done: [task description]"**:

1. Add to completed tasks list
2. Acknowledge completion
3. Show remaining tasks

```python
# Store completed tasks in memory
completed_tasks = []

def mark_task_done(task_description):
    completed_tasks.append({
        'task': task_description,
        'time': datetime.now().strftime('%H:%M'),
        'team': categorize_team(task_description)
    })
    
    return f"✅ Task completed at {datetime.now().strftime('%H:%M')}\nRemaining: {total - len(completed_tasks)} tasks"
```

---

### Phase 3: Update Team Daily Sheet

#### Format for Team Daily Update

When Tara says **"update daily sheet"** or at EOD:

```python
def format_daily_update(completed_tasks, start_time, end_time, hours):
    # Separate by team
    website_tasks = [t for t in completed_tasks if t['team'] == 'WEBSITE']
    software_tasks = [t for t in completed_tasks if t['team'] == 'SOFTWARE']
    freelance_tasks = [t for t in completed_tasks if t['team'] == 'FREELANCE']
    
    # Build format
    output = ""
    
    if website_tasks:
        output += "Website\n"
        for task in website_tasks:
            output += f" - {task['task']}\n"
    
    if software_tasks:
        output += "Software\n"
        for task in software_tasks:
            output += f" - {task['task']}\n"
    
    output += f"\nWorking Hours : {hours} Hrs\n"
    
    if freelance_tasks:
        output += "Freelance Wala\n"
        for task in freelance_tasks:
            output += f" - {task['task']}\n"
    
    return output
```

#### Update Sheet Command

```bash
# Get today's row
TODAY=$(date +%-d-%-m-%Y)  # e.g., 23-2-2026

# Find row with today's date
gog sheets get 1GgRgfVBrF-ReGPRmntT6Cm2BjiLzJ3JiBaC4lMfrMQs "February 2026 Daily Updates!A:A" --json | \
python3 -c "
import sys, json
data = json.load(sys.stdin)
values = data.get('values', [])
target_date = '$TODAY'

for i, row in enumerate(values, start=1):
    if row and row[0] == target_date:
        print(f'Row {i}')
        break
"

# Update the cell
gog sheets update 1GgRgfVBrF-ReGPRmntT6Cm2BjiLzJ3JiBaC4lMfrMQs \
    "February 2026 Daily Updates!B{row}" \
    --values-json '[["Website\n - Task 1\n - Task 2\n\nSoftware\n - Task 1\n\nWorking Hours : 9 Hrs"]]'
```

---

### Phase 4: EOD Summary

#### Compare Planned vs Completed

When Tara says **"EOD summary"**:

```
📊 END OF DAY SUMMARY - 23/02/2026

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ COMPLETED (7/10 tasks)

SOFTWARE:
  ✅ PMS Bug - Weekly report status
  ✅ Test 15 issues from GitHub
  ✅ Update PMS tracker sheet
  ✅ Curriculum designer YouTube API

WEBSITE:
  ✅ Update homepage content
  ✅ Fix mobile responsiveness
  ✅ Review annual report page

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⏳ PENDING (3 tasks)

  ❌ Research clawdbot integration (SOFTWARE)
  ❌ Update documentation (WEBSITE)
  ❌ Weekly report submission (WEBSITE)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📈 Stats:
  • Completion Rate: 70%
  • Working Hours: 9 hrs
  • Teams Worked: Software, Website

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 Want me to update the Team Daily sheet now?
Reply "yes" to update the sheet.
```

---

## Sheet Structures

### Weekly Target Sheet (Tech Tab)

| Column | Name | Example |
|--------|------|---------|
| A | Week | WEEK 1 |
| B | Month | FEB |
| C | Tasks | Fix login bug |
| D | Assigned To | TARA |
| E | Team | SOFTWARE |
| F | Dependencies | Design team |
| G | Priority | P0 |
| H | Status | IN PROGRESS |
| I | Blockers/Delays | Waiting for API |
| J | Achievements | Bug fixed |
| K | Notes | Link to PR |

### Team Daily Update Sheet

| Column | Content |
|--------|---------|
| A | Date (D-M-YYYY) |
| B | Tara's tasks (formatted) |
| C | Shailendra's tasks |
| D | Pranav's tasks |
| ... | Other team members |

---

## Task Categorization

### Team Detection

```python
def categorize_team(task_text):
    task_lower = task_text.lower()
    
    software_keywords = ['pms', 'github', 'api', 'code', 'bug', 'feature', 
                         'curriculum designer', 'integration', 'software']
    website_keywords = ['website', 'page', 'homepage', 'content', 'update',
                        'fix', 'mobile', 'responsive']
    freelance_keywords = ['freelance', 'aman', 'client', 'fw ']
    
    if any(kw in task_lower for kw in software_keywords):
        return 'SOFTWARE'
    elif any(kw in task_lower for kw in website_keywords):
        return 'WEBSITE'
    elif any(kw in task_lower for kw in freelance_keywords):
        return 'FREELANCE'
    else:
        return 'OTHER'
```

---

## Conversation Examples

### Example 1: Morning Planning

**Tara:** "Plan my day"

**Anukar:**
```
📋 Good Morning! Fetching your tasks...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔹 SOFTWARE (5 tasks)
  1. [P0] PMS Bug - Weekly report status
  2. [P0] Curriculum designer - YouTube API
  3. [P1] Test 15 GitHub issues
  4. [P1] Update PMS tracker
  5. [P2] Research clawdbot integration

🌐 WEBSITE (3 tasks)
  6. [P1] Update homepage
  7. [P1] Fix mobile responsive
  8. [P2] Review annual report

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Which tasks for today? (e.g., "1, 2, 3, 6, 7")
```

**Tara:** "1, 3, 4, 6, 7"

**Anukar:**
```
✅ 5 tasks selected!

📱 WhatsApp Format:

Work Start 10:00 AM: 

*SOFTWARE*: 
1. PMS Bug - Weekly report status
2. Test 15 GitHub issues
3. Update PMS tracker

*WEBSITE*: 
1. Update homepage
2. Fix mobile responsive

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

I'll track these. Say "task done: [description]" as you complete them!
```

---

### Example 2: Throughout Day

**Tara:** "task done: updated pms tracker"

**Anukar:**
```
✅ Completed at 2:30 PM

Progress: 1/5 tasks done
Remaining:
  - PMS Bug - Weekly report status
  - Test 15 GitHub issues
  - Update homepage
  - Fix mobile responsive
```

---

### Example 3: EOD

**Tara:** "EOD summary"

**Anukar:**
```
📊 END OF DAY SUMMARY

✅ COMPLETED (4/5)

SOFTWARE:
  ✅ PMS Bug - Weekly report status
  ✅ Test 15 GitHub issues
  ✅ Update PMS tracker

WEBSITE:
  ✅ Update homepage

⏳ PENDING (1)
  ❌ Fix mobile responsive

📈 Completion: 80% | Hours: 9

Update Team Daily sheet? (yes/no)
```

**Tara:** "yes"

**Anukar:**
```
✅ Team Daily Update sheet updated!

Row 23, Column B updated with:
- 5 completed tasks
- 9 working hours
```

---

## Notes

- Tasks are tracked in memory during the session
- At EOD, data is written to Team Daily Update sheet
- Weekly Target sheet is read-only (status updates manual)
- Supports ad-hoc tasks via "add task: [description]"

---

## Google Tasks Integration

### Overview

Tasks sync between Weekly Sheet → Google Tasks → Team Daily Sheet for seamless mobile access.

### Task List

- **List Name:** AP Weekly Tasks
- **List ID:** `YXdrWnhDNkYzWldMc2plaQ`
- **Access:** https://tasks.google.com (login with anukar2004@gmail.com)

### Morning Sync (10:00 AM)

After reading Weekly Sheet, sync tasks to Google Tasks:

```bash
TASK_LIST_ID="YXdrWnhDNkYzWldMc2plaQ"

# Clear existing tasks (optional)
# gog tasks list "$TASK_LIST_ID" --json | python3 -c "parse and delete"

# Add new tasks
for task in weekly_tasks:
    gog tasks add "$TASK_LIST_ID" \
        --title "[{priority}] {team}: {task_name}" \
        --notes "{notes}. Week {week}, {month} {year}."
```

### Throughout the Day

#### Check Task Status

```bash
gog tasks list "YXdrWnhDNkYzWldMc2plaQ" --json | python3 -c "
import sys, json

data = json.load(sys.stdin)
tasks = data.get('tasks', [])

print('📊 TASK STATUS:')
print()

completed = [t for t in tasks if t['status'] == 'completed']
pending = [t for t in tasks if t['status'] == 'needsAction']

print(f'✅ Completed: {len(completed)}')
print(f'⏳ Pending: {len(pending)}')
print()

for task in pending:
    print(f\"  - {task['title']}\")
"
```

#### Mark Task Complete

When Tara says "task done: [description]":

```bash
# Find task by title
TASK_ID=$(gog tasks list "$TASK_LIST_ID" --json | \
    python3 -c "import sys,json; tasks=json.load(sys.stdin)['tasks']; [print(t['id']) for t in tasks if 'search_term' in t['title'].lower()]")

# Mark as complete
gog tasks done "$TASK_LIST_ID" "$TASK_ID"
```

### EOD Auto-Update

Read completed tasks from Google Tasks and update Team Daily Sheet:

```bash
# Get completed tasks
gog tasks list "YXdrWnhDNkYzWldMc2plaQ" --json | python3 -c "
import sys, json
from datetime import datetime, timedelta

data = json.load(sys.stdin)
tasks = data.get('tasks', [])

# Get today's completed tasks
today = datetime.now().strftime('%Y-%m-%d')
completed_today = []

for task in tasks:
    if task['status'] == 'completed':
        completed_date = task.get('completed', '')[:10]
        if completed_date == today:
            completed_today.append(task['title'])

# Format for Team Daily Sheet
software = [t for t in completed_today if 'SOFTWARE' in t.upper()]
website = [t for t in completed_today if 'WEBSITE' in t.upper()]

output = ''
if website:
    output += 'Website\\n'
    for t in website:
        # Remove [P0], [P1], etc.
        clean = t.split(']')[-1].strip().replace('Website:', '').strip()
        output += f' - {clean}\\n'

if software:
    output += 'Software\\n'
    for t in software:
        clean = t.split(']')[-1].strip().replace('Software:', '').strip()
        output += f' - {clean}\\n'

print(output)
"
```

### Benefits

| Feature | Benefit |
|---------|---------|
| **Mobile Access** | Check/completed tasks on phone |
| **Auto-sync** | Updates reflected everywhere |
| **Reminders** | Get notified about pending tasks |
| **One-tap complete** | Faster than typing |
| **Auto-update sheet** | No manual entry needed |

### Google Tasks Links

- **Web:** https://tasks.google.com
- **Android:** Google Tasks app (pre-installed)
- **iOS:** Download Google Tasks app

---

## Automation Schedule

| Time | Action |
|------|--------|
| **10:00 AM** | Sync weekly tasks to Google Tasks |
| **Every 2 hours** | Check task status, send reminder if needed |
| **5:00 PM** | Read completed tasks, update Team Daily Sheet |
| **6:00 PM** | Send EOD summary |

---

## Example: Complete Integration Flow

```
10:00 AM - Tara arrives
├─ Anukar: "Plan my day"
├─ Read Weekly Sheet (Tech tab)
├─ Show tasks for selection
├─ Sync to Google Tasks
└─ Generate WhatsApp format

2:00 PM - Midday check
├─ Tara checks Google Tasks on phone
├─ Taps "Complete" on finished tasks
└─ Anukar: "2/4 tasks done. Keep going!"

5:30 PM - End of day
├─ Anukar reads Google Tasks
├─ Gets 3 completed tasks
├─ Updates Team Daily Sheet automatically
└─ Sends EOD summary: "75% completion rate"
```
