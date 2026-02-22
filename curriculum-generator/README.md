# Curriculum Generator Skill

📚 A multi-agent skill that generates structured curricula following the SOP pattern.

## Overview

This skill uses multiple agents to:
1. Ask clarifying questions
2. Research and find quality resources
3. Create a structured Google Sheet
4. Deliver the sheet to the user

## Usage

```
User: "Generate curriculum for P0 PODs on web development"

Anukar: [Asks questions about POD type, focus, content types, etc.]
User: [Answers questions]
Anukar: [Spawns researcher to find resources]
Anukar: [Spawns comms to create sheet]
Anukar: 📚 Curriculum Generated!
        📊 Sheet: [URL]
```

## Agents Used

| Agent | Role |
|-------|------|
| Researcher | Find and organize resources |
| Comms | Create and format Google Sheet |

## Sheet Structure

| Column | Description |
|--------|-------------|
| Curriculum ID | Unique identifier |
| File Name | Curriculum name |
| Target POD Type | P0/P1/P2/P3 |
| Clusters | Topic clusters |
| Content Type | Video/Reading/Exercise |
| Covered Topics | List of topics |
| Owner | Creator name |
| Resource Link | URL to resource |
| Document Created | Creation date |
| Last Updated On | Update date |

## Sheet Storage

- **Folder:** https://drive.google.com/drive/folders/1upJQu-IVmZRJQsNGmJNRzq9IwL67MVL9
- **Naming:** Curriculum_[POD]_[Topic]_[YYYY-MM-DD]

## Files

```
curriculum-generator/
├── SKILL.md              # Main skill definition
├── README.md             # This file
├── prompts/
│   ├── questions.md      # Question templates
│   ├── researcher-task.md # Researcher instructions
│   └── comms-task.md     # Comms instructions
└── templates/
    └── sheet-structure.json # Sheet column definitions
```

## Author
Anukar AI Assistant

## Version
1.0.0
