---
name: obsidian
description: "Interact with Obsidian vaults for personal knowledge management. Create, read, update, and organize notes. Build a second brain with Zettelkasten principles. Triggers: 'obsidian', 'note', 'vault', 'knowledge base', 'second brain'."
---

# Obsidian Knowledge Base Skill

Interact with Obsidian vaults for personal knowledge management.

## Trigger
- **"Obsidian [action]"** → Any Obsidian operation
- **"Create note: [title]"** → Create new note
- **"Read note: [title]"** → Read existing note
- **"Search notes: [query]"** → Search vault
- **"Daily note"** → Create/open daily note
- **"Knowledge base"** → Knowledge base operations

---

## Vault Configuration

| Setting | Value |
|---------|-------|
| **Vault Path** | `/home/aptest/Documents/Obsidian Vault` |
| **Daily Notes** | `Daily Notes/` |
| **Templates** | `Templates/` |
| **Attachments** | `Attachments/` |

---

## Core Operations

### Create Note

```bash
# Create a new note
NOTE_TITLE="$1"
NOTE_PATH="$HOME/Documents/Obsidian Vault/${NOTE_TITLE}.md"

# Create with template
cat > "$NOTE_PATH" << EOF
---
created: $(date +%Y-%m-%d)
modified: $(date +%Y-%m-%d)
tags: []
---

# ${NOTE_TITLE}

EOF

echo "✅ Note created: $NOTE_PATH"
```

### Read Note

```bash
NOTE_PATH="$HOME/Documents/Obsidian Vault/${1}.md"
cat "$NOTE_PATH"
```

### Search Notes

```bash
grep -rn "$1" "$HOME/Documents/Obsidian Vault/" --include="*.md"
```

### Daily Note

```bash
TODAY=$(date +%Y-%m-%d)
DAILY_PATH="$HOME/Documents/Obsidian Vault/Daily Notes/${TODAY}.md"

mkdir -p "$(dirname "$DAILY_PATH")"

if [ ! -f "$DAILY_PATH" ]; then
    cat > "$DAILY_PATH" << EOF
---
created: $(date +%Y-%m-%d)
type: daily
---

# $(date +"%A, %B %d, %Y")

## 📋 Tasks
- [ ] 

## 📝 Notes


## 💡 Ideas


## 🔗 Links

EOF
fi

cat "$DAILY_PATH"
```

---

## Knowledge Base Structure

### Folder Structure

```
Obsidian Vault/
├── 00 - Inbox/              # Quick capture
├── 01 - Projects/           # Active projects
├── 02 - Areas/              # Life areas (health, work, etc.)
├── 03 - Resources/          # Reference material
├── 04 - Archives/           # Completed/inactive
├── 05 - Templates/          # Note templates
├── Daily Notes/             # Daily journal
├── Fleeting Notes/          # Quick thoughts
└── Permanent Notes/         # Zettelkasten notes
```

### Note Types

1. **Fleeting Notes** - Quick capture, processed later
2. **Literature Notes** - Notes from sources
3. **Permanent Notes** - Atomic ideas (Zettelkasten)
4. **Project Notes** - Project-specific
5. **Daily Notes** - Journal entries
6. **Resource Notes** - Reference material

---

## Zettelkasten Implementation

### Atomic Notes

Each permanent note contains:
- One single idea
- Unique ID (timestamp-based)
- Links to related notes
- Source reference

### Note ID Format

```
YYYYMMDDHHMM - Brief Title
Example: 202602242200 - Automation Philosophy
```

### Linking

```markdown
- Related: [[202602242100 - Task Automation]]
- Source: [[Book - Atomic Habits]]
- Applies to: [[Project - PMS Dashboard]]
```

---

## Templates

### Meeting Note Template

```markdown
---
created: {{date}}
type: meeting
attendees: []
---

# Meeting: {{title}}

**Date:** {{date}}
**Time:** {{time}}
**Attendees:** 

## Agenda
1. 

## Notes


## Action Items
- [ ] 

## Follow-up

```

### Project Note Template

```markdown
---
created: {{date}}
type: project
status: active
---

# Project: {{title}}

## Overview
Brief description

## Goals
- [ ] Goal 1
- [ ] Goal 2

## Tasks
- [ ] 

## Resources
- 

## Notes


## Related
- 

```

### Person Note Template

```markdown
---
created: {{date}}
type: person
---

# {{name}}

## Contact
- Email: 
- Phone: 
- LinkedIn: 

## Context
Where/How we met

## Notes


## Interactions
- {{date}}: 

```

---

## Commands

| Command | Action |
|---------|--------|
| `obsidian create "[title]"` | Create new note |
| `obsidian read "[title]"` | Read note |
| `obsidian search "[query]"` | Search vault |
| `obsidian daily` | Open daily note |
| `obsidian inbox "[note]"` | Quick capture |
| `obsidian link "[from]" "[to]"` | Link notes |

---

## Integration with Anukar

### Automatic Logging

Anukar can automatically log to Obsidian:
- Daily achievements → Daily Note
- New skills created → Knowledge Base
- Meeting summaries → Meeting Notes
- Project updates → Project Notes

### Sync Points

| Anukar Data | Obsidian Location |
|-------------|-------------------|
| Daily achievements | `Daily Notes/` |
| Skill documentation | `Resources/Skills/` |
| Meeting notes | `Resources/Meetings/` |
| Project progress | `Projects/` |

---

## Setup Commands

```bash
# Create folder structure
mkdir -p "$HOME/Documents/Obsidian Vault/"{00\ -\ Inbox,01\ -\ Projects,02\ -\ Areas,03\ -\ Resources,04\ -\ Archives,05\ -\ Templates,Daily\ Notes,Fleeting\ Notes,Permanent\ Notes}

# Create templates
mkdir -p "$HOME/Documents/Obsidian Vault/05 - Templates"
```

---

## Notes

- Obsidian vaults are just folders with markdown files
- `.obsidian/` folder contains settings and plugins
- Use wikilinks `[[Note Name]]` for internal links
- Tags: `#tag` anywhere in note
- Frontmatter: YAML between `---` at top
