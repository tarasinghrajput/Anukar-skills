# Comms Task: Create Curriculum Sheet

## Context
You are creating a Google Sheet for a curriculum based on researcher's data.

## Input Data
[Researcher's JSON will be inserted here by Anukar Core]

## Your Tasks

### 1. Create Google Sheet

Use gog CLI to create the sheet in the correct folder:

```bash
# Create sheet in designated folder
gog sheets create \
  --title "[Curriculum Name]" \
  --folder "1upJQu-IVmZRJQsNGmJNRzq9IwL67MVL9" \
  --account anukar2004@gmail.com
```

### 2. Sheet Naming Convention

Format: `Curriculum_[POD]_[Topic]_[YYYY-MM-DD]`

Examples:
- Curriculum_P0_WebDevelopment_2026-02-22
- Curriculum_P1_PythonBasics_2026-02-22

### 3. Add Headers (Row 1)

| Column | Header |
|--------|--------|
| A | Curriculum ID |
| B | File Name |
| C | Target POD Type |
| D | Clusters |
| E | Content Type |
| F | Covered Topics |
| G | Owner |
| H | Resource Link |
| I | Document Created |
| J | Last Updated On |

```bash
gog sheets update [SHEET_ID] "A1:J1" --values '[["Curriculum ID","File Name","Target POD Type","Clusters","Content Type","Covered Topics","Owner","Resource Link","Document Created","Last Updated On"]]'
```

### 4. Add Data Rows

For each resource in the researcher's JSON, add a row:

```bash
gog sheets append [SHEET_ID] "A:J" --values '[[CUR-2026-02-22-001","Curriculum_P0_WebDev_2026-02-22","P0","HTML Fundamentals","video","HTML tags, elements","Anukar","https://youtube.com/...","2026-02-22","2026-02-22"]]'
```

### 5. Share Settings

```bash
# Make viewable by anyone with link
gog sheets share [SHEET_ID] --type anyone --role viewer

# Grant edit access to owner
gog sheets share [SHEET_ID] --email tarasinghrajput7261@gmail.com --role writer
```

### 6. Return Output

Return this information:
```json
{
  "sheetId": "...",
  "sheetUrl": "https://docs.google.com/spreadsheets/d/...",
  "sheetName": "Curriculum_P0_WebDev_2026-02-22",
  "rowsAdded": 15,
  "clusters": 5,
  "totalResources": 15
}
```

### 7. Dashboard Logging

```bash
cd /home/aptest/.openclaw/workspace/Anukar-Dashboard/backend
node agentCli.js start comms "Curriculum Sheet" "Creating sheet for [Topic]"
node agentCli.js complete comms "[TASK_ID]" "Curriculum Sheet" "Created sheet with X resources" "sheets/[sheetId]" "sheet"
```

## Target Folder

- **Folder ID:** 1upJQu-IVmZRJQsNGmJNRzq9IwL67MVL9
- **Folder URL:** https://drive.google.com/drive/folders/1upJQu-IVmZRJQsNGmJNRzq9IwL67MVL9

## Important

- ALWAYS create sheets in the designated folder
- ALWAYS follow the naming convention
- ALWAYS include all 10 columns
- ALWAYS share with edit access
- ALWAYS return the full sheet URL
