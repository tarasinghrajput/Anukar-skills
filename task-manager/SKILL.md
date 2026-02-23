---
name: task-manager
description: "Manage Tara's daily tasks using Option C workflow. Weekly goals from sheet → Morning planning → Daily tasks in Google Tasks → EOD tracking. Triggers: 'plan my day', 'task done', 'add daily task', 'EOD summary', 'update daily sheet'."
---

# Task Manager (Option C Workflow)

Manage Tara's daily task workflow: Weekly Goals → Daily Planning → Execution → Tracking.

## Trigger
- **"Plan my day"** → Morning planning (create daily tasks from weekly goals)
- **"Task done: [task]"** → Mark daily task complete
- **"Add daily task: [task]"** → Add ad-hoc daily task
- **"EOD summary"** → End of day comparison
- **"Update daily sheet"** → Sync completed tasks to Team Daily sheet

---

## Resource References

| Resource | ID | Purpose |
|----------|-------|---------|
| **Weekly Targets Sheet** | `1to3web3WdMHlGWGnu5BieMX2QZ0AN9J0iTgLRZac5T4` | Tech tab - weekly goals |
| **Team Daily Update Sheet** | `1GgRgfVBrF-ReGPRmntT6Cm2BjiLzJ3JiBaC4lMfrMQs` | Daily progress log |
| **Google Tasks - Weekly Goals** | `YXdrWnhDNkYzWldMc2plaQ` | AP Weekly Tasks (reference) |
| **Google Tasks - Daily Tasks** | `S0JZaWNEVnZpcms2d1JDNQ` | AP Daily Tasks (today's focus) |

---

## Option C Workflow

```
┌─────────────────────────────────────────────────────────────┐
│                    OPTION C WORKFLOW                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  PHASE 1: MORNING PLANNING (10:00-10:30 AM)                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 1. Read Weekly Goals from Tech tab                  │   │
│  │ 2. Show weekly goals to Tara                        │   │
│  │ 3. Ask: "What will you focus on TODAY?"             │   │
│  │ 4. Create DAILY tasks in Google Tasks               │   │
│  │ 5. Generate WhatsApp format                         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  PHASE 2: THROUGHOUT THE DAY                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Tara completes tasks on phone/laptop                │   │
│  │ Says "task done: [description]" for tracking        │   │
│  │ OR checks off in Google Tasks directly              │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  PHASE 3: END OF DAY (5:30-6:00 PM)                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 1. Read completed tasks from Google Tasks           │   │
│  │ 2. Map back to weekly goals (progress %)            │   │
│  │ 3. Update Team Daily Update sheet                   │   │
│  │ 4. Show EOD summary                                  │   │
│  │ 5. Clear daily tasks (prepare for tomorrow)         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Phase 1: Morning Planning

### Step 1: Read Weekly Goals

```bash
WEEKLY_SHEET="1to3web3WdMHlGWGnu5BieMX2QZ0AN9J0iTgLRZac5T4"

# Get current week/month
python3 -c "
from datetime import datetime
today = datetime.now()
week_num = today.isocalendar()[1]
month = today.strftime('%b').upper()
print(f'WEEK {week_num}', month)
"

# Fetch Tara's weekly goals
gog sheets get $WEEKLY_SHEET "Tech!A:K" --json | python3 -c "
import sys, json
from datetime import datetime

data = json.load(sys.stdin)
values = data.get('values', [])

# Get current week
today = datetime.now()
current_week = f'WEEK {today.isocalendar()[1]}'
current_month = today.strftime('%b').upper()

weekly_goals = []

for row in values[1:]:
    if len(row) >= 8:
        week = row[0] if len(row) > 0 else ''
        month = row[1] if len(row) > 1 else ''
        assigned_to = row[3] if len(row) > 3 else ''
        task = row[2] if len(row) > 2 else ''
        team = row[4] if len(row) > 4 else ''
        priority = row[6] if len(row) > 6 else ''
        status = row[7] if len(row) > 7 else ''
        
        if ('TARA' in assigned_to.upper() and 
            current_week in week.upper() and 
            current_month in month.upper() and
            'COMPLETE' not in status.upper()):
            
            weekly_goals.append({
                'priority': priority,
                'team': team,
                'task': task,
                'status': status
            })

# Display
print('📋 YOUR WEEKLY GOALS:')
print('=' * 60)
print()

for i, goal in enumerate(weekly_goals, 1):
    print(f\"{i}. [{goal['priority']}] {goal['team']}\")
    print(f\"   {goal['task'][:80]}\")
    print()
"
```

### Step 2: Ask for Daily Focus

After showing weekly goals, ask:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

What do you want to focus on TODAY?

Tell me what you'll work on (be specific):
- "Auth module of Apni Prerna"
- "Test 3 PMS bugs"
- "Setup clawdbot environment"

Example: "Auth module and test weekly report bug in PMS"
```

### Step 3: Create Daily Tasks

When Tara responds with focus areas:

```bash
DAILY_TASK_LIST="S0JZaWNEVnZpcms2d1JDNQ"

# For each focus area, create a daily task
gog tasks add "$DAILY_TASK_LIST" \
    --title "Review Apni Prerna authentication module" \
    --notes "Part of: Go-through Apni Prerna codebase. Date: $(date +%d-%b-%Y)"

gog tasks add "$DAILY_TASK_LIST" \
    --title "Test PMS weekly report status feature" \
    --notes "Part of: Ensure PMS ready to launch. Date: $(date +%d-%b-%Y)"
```

### Step 4: Generate WhatsApp Format

```python
def generate_whatsapp_format(daily_tasks, start_time="10:00 AM"):
    software = [t for t in daily_tasks if 'SOFTWARE' in t.get('team', '').upper()]
    website = [t for t in daily_tasks if 'WEBSITE' in t.get('team', '').upper()]
    
    output = f"Work Start {start_time}:\n\n"
    
    if software:
        output += "*SOFTWARE*:\n"
        for i, task in enumerate(software, 1):
            output += f"{i}. {task['title']}\n"
        output += "\n"
    
    if website:
        output += "*WEBSITE*:\n"
        for i, task in enumerate(website, 1):
            output += f"{i}. {task['title']}\n"
    
    return output
```

---

## Phase 2: Throughout the Day

### Mark Task Complete

When Tara says "task done: [description]":

```bash
DAILY_TASK_LIST="S0JZaWNEVnZpcms2d1JDNQ"

# Find matching task
TASK_ID=$(gog tasks list "$DAILY_TASK_LIST" --json | python3 -c "
import sys, json
search_term = 'authentication'  # from Tara's message
data = json.load(sys.stdin)
tasks = data.get('tasks', [])
for task in tasks:
    if search_term.lower() in task['title'].lower():
        print(task['id'])
        break
")

# Mark as complete
gog tasks done "$DAILY_TASK_LIST" "$TASK_ID"
```

---

## Phase 3: End of Day

### Get Completed Tasks

```bash
DAILY_TASK_LIST="S0JZaWNEVnZpcms2d1JDNQ"

gog tasks list "$DAILY_TASK_LIST" --json | python3 -c "
import sys, json
from datetime import datetime

data = json.load(sys.stdin)
tasks = data.get('tasks', [])

completed = [t for t in tasks if t['status'] == 'completed']
pending = [t for t in tasks if t['status'] == 'needsAction']

print(f'📊 EOD SUMMARY - {datetime.now().strftime(\"%d/%m/%Y\")}')
print('=' * 60)
print()

print('✅ COMPLETED:')
for task in completed:
    print(f\"  - {task['title']}\")

print()
print('⏳ PENDING:')
for task in pending:
    print(f\"  - {task['title']}\")

print()
print(f'Completion Rate: {len(completed)}/{len(tasks)} ({len(completed)*100//len(tasks) if tasks else 0}%)')
"
```

### Update Team Daily Sheet

```bash
TEAM_DAILY_SHEET="1GgRgfVBrF-ReGPRmntT6Cm2BjiLzJ3JiBaC4lMfrMQs"
TODAY=$(date +%-d-%-m-%Y)
MONTH_YEAR=$(date +"%B %Y")  # "February 2026"

# Get completed tasks
COMPLETED_DATA=$(gog tasks list "$DAILY_TASK_LIST" --json | python3 -c "
import sys, json
data = json.load(sys.stdin)
tasks = data.get('tasks', [])

completed = [t for t in tasks if t['status'] == 'completed']

software = []
website = []
freelance = []

for task in completed:
    title = task['title']
    notes = task.get('notes', '')
    
    if 'SOFTWARE' in notes.upper() or 'software' in title.lower():
        software.append(title)
    elif 'WEBSITE' in notes.upper() or 'website' in title.lower():
        website.append(title)

# Format for sheet
output = ''
if website:
    output += 'Website\\n'
    for t in website:
        output += f' - {t}\\n'

if software:
    output += 'Software\\n'
    for t in software:
        output += f' - {t}\\n'

print(output)
")

# Find today's row
ROW=$(gog sheets get "$TEAM_DAILY_SHEET" "${MONTH_YEAR} Daily Updates!A:A" --json | python3 -c "
import sys, json
data = json.load(sys.stdin)
values = data.get('values', [])
target = '$TODAY'
for i, row in enumerate(values, start=1):
    if row and row[0] == target:
        print(i)
        break
")

# Update the cell
gog sheets update "$TEAM_DAILY_SHEET" "${MONTH_YEAR} Daily Updates!B${ROW}" \
    --values-json "[[\"$COMPLETED_DATA\"]]"
```

### Clear Daily Tasks (Prepare for Tomorrow)

```bash
# Delete all tasks from daily list at EOD
gog tasks list "$DAILY_TASK_LIST" --json | python3 -c "
import sys, json, subprocess
data = json.load(sys.stdin)
tasks = data.get('tasks', [])
for task in tasks:
    subprocess.run(['gog', 'tasks', 'delete', '$DAILY_TASK_LIST', task['id']], 
                   capture_output=True)
"
```

---

## Cron Schedule

| Cron Job | Time | Days | Purpose |
|----------|------|------|---------|
| morning-task-reminder | 10:30 AM IST | Mon-Sat | Remind to plan day |
| ID: `720a3349-5954-400d-bf2c-9c6b51f2aa62` | | | |

---

## Progress Tracking

### Weekly Progress Mapping

| Weekly Goal | Daily Tasks Done | Progress |
|-------------|------------------|----------|
| Apni Prerna codebase | Auth module, User mgmt, API review | 60% |
| PMS ready to launch | Tested 8 bugs, Fixed 3 | 75% |
| Clawdbot research | Setup, API docs, Integration test | 80% |

---

## Conversation Examples

### Example 1: Morning Planning

**Tara:** "Plan my day"

**Anukar:**
```
📋 YOUR WEEKLY GOALS (Week 4, FEB)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔹 SOFTWARE
1. [P0] Ensure PMS is ready to launch and bug free
2. [P0] Go-through Apni Prerna codebase (20-25 features)
3. [P1] Clawdbot research for curriculum design

🌐 WEBSITE
4. [P1] Checkout tasks from interns

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

What do you want to focus on TODAY?

Be specific (these will be your daily tasks):
- "Auth module of Apni Prerna"
- "Test 3 PMS bugs"
- "Setup clawdbot"
```

**Tara:** "Auth module and test 3 PMS bugs"

**Anukar:**
```
✅ Creating daily tasks in Google Tasks...

📝 Today's Focus:
1. Review Apni Prerna authentication module
2. Test PMS - weekly report status
3. Test PMS - notification system
4. Test PMS - search functionality

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📱 WhatsApp Format:

Work Start 10:00 AM:

*SOFTWARE*: 
1. Review Apni Prerna authentication module
2. Test PMS - weekly report status
3. Test PMS - notification system
4. Test PMS - search functionality

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ 4 tasks added to Google Tasks!
Check them off on your phone as you complete them.
```

---

### Example 2: Task Done

**Tara:** "task done: auth module review complete"

**Anukar:**
```
✅ Completed at 2:30 PM!

Progress: 1/4 tasks done
Remaining:
  - Test PMS - weekly report status
  - Test PMS - notification system
  - Test PMS - search functionality
```

---

### Example 3: EOD Summary

**Tara:** "EOD summary"

**Anukar:**
```
📊 END OF DAY SUMMARY - 23/02/2026
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ COMPLETED (3/4 - 75%)

SOFTWARE:
  ✅ Review Apni Prerna authentication module
  ✅ Test PMS - weekly report status
  ✅ Test PMS - notification system

⏳ PENDING (1)
  ❌ Test PMS - search functionality

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📈 Weekly Progress:
  • Apni Prerna: Auth module done (20% of goal)
  • PMS: 3 bugs tested (30% of goal)

Update Team Daily sheet? (yes/no)
```

---

## Notes

- Weekly goals are READ-ONLY (updated manually in sheet)
- Daily tasks are CREATED each morning
- Daily tasks are CLEARED each EOD
- Progress mapped back to weekly goals for tracking
- Google Tasks syncs across all devices
