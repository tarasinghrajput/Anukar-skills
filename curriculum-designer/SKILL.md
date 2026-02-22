---
name: curriculum-designer
description: "Design customized curricula for PODs. Use when user says 'Design curriculum', 'Create curriculum for POD', or 'Build learning plan'. Gathers requirements, researches resources, and creates a structured curriculum sheet with daily objectives, assessments, and video links."
---

# Curriculum Designer

Design customized curricula for Apni Pathshala PODs based on Madhur's workflow.

## Trigger
User message contains:
- **"Design curriculum"** → Start curriculum creation
- **"Create curriculum for [POD name]"** → Start with POD context
- **"Build learning plan"** → Start curriculum creation
- **"Curriculum for [subject/topic]"** → Start with topic context

## Target User
This skill is designed for **Madhur** (Academic Associate) who designs curricula for PODs.

---

## Workflow

### Phase 1: Gather Requirements

Ask the following questions (from SOP) to understand the POD's needs:

#### Basic Information
1. **POD Name** - Which POD is this curriculum for?
2. **Target Audience** - Grade level or age group of students?
3. **Subject Areas** - What subjects/topics should be covered?
4. **Duration** - How long is the program? (e.g., 1 month, 3 months, 6 months)
5. **Frequency** - How many classes per week?
6. **Daily Lab Hours** - How many hours will the lab operate?
7. **Previous Exposure** - Have students done digital learning before?

#### Teacher Context
8. **Teacher Capability** - Can teachers operate computers independently?
9. **Teacher Training Needed** - Do teachers need any training to deliver this curriculum?

#### Learning Outcomes
10. **Learning Area Focus** - Which area(s) to prioritize?
    - Digital Literacy
    - Academic Empowerment
    - Skill Development
    - Employment Readiness
11. **Specific Skills** - What specific skills should students acquire by the end?
12. **Assessment Method** - How will learning be measured? (quizzes, projects, exams)

---

### Phase 2: Research Resources

Before drafting the curriculum, research relevant free resources:

**Research Steps:**
1. Search for free video resources on the topic (YouTube, Khan Academy, etc.)
2. Find interactive tools and platforms (free tier)
3. Look for existing curricula/templates in the Apni Pathshala drive
4. Identify age-appropriate content

**Video Requirements:**
- ⚠️ Videos should be **5-10 minutes max** to maintain student interest
- Avoid long-form content (boring for students)
- Prefer Hindi/English bilingual content for accessibility

---

### Phase 3: Design Curriculum Structure

Based on requirements, create a structured curriculum with:

#### Learning Areas Framework
| Learning Area | Focus |
|---------------|-------|
| Digital Literacy | Basic computer skills, internet safety, AI tools |
| Academic Empowerment | Study skills, exam prep, note-taking |
| Skill Development | Programming, design, content creation |
| Employment Readiness | Resume, communication, job skills |

#### Module Structure
For each module:
- **Module Name** - Clear topic name
- **Duration** - Number of days/sessions
- **Learning Objectives** - What students will learn
- **Assessments** - How to measure progress
- **Resources** - Video links, tools needed

---

### Phase 4: Create Curriculum Sheet

**Output Format:** Google Sheet with the following columns:

| Column | Description |
|--------|-------------|
| Day | Day number (1, 2, 3...) |
| Subject | Subject area / Learning area |
| Module | Module/Topic name |
| Daily Learning Objectives | What students learn that day |
| Daily Assessment | How to assess understanding |
| YouTube Link | Video resource (5-10 min) |
| Tools Used | Required software/platforms |

**Sheet Creation Commands:**
```bash
# Create new sheet in the Curriculum Designer folder
# Folder ID: 1upJQu-IVmZRJQsNGmJNRzq9IwL67MVL9

# Build the curriculum data as JSON
# Then create the sheet with gog
```

---

### Phase 5: Save and Share

1. **Create the sheet** in the Curriculum Designer folder
2. **Set up columns** with headers
3. **Populate with curriculum data** (all days/lessons)
4. **Get shareable link** with "Anyone with link can view"
5. **Return the link** to Madhur

---

## Curriculum Sheet Template

```json
{
  "headers": ["Day", "Subject", "Module", "Daily Learning Objectives", "Daily Assessment", "YouTube Link", "Tools Used"],
  "rows": [
    {
      "day": 1,
      "subject": "AI Basics – Understanding & Safe Use",
      "module": "AI Basics – What is AI + GenAI (simple)",
      "objectives": "Understand what AI is, where students see it daily, and what GenAI means.",
      "assessment": "Write 3 examples of AI you use daily + 2 benefits + 1 risk.",
      "youtube": "https://youtube.com/...",
      "tools": "Notebook, Phone/PC"
    }
  ]
}
```

---

## Important Guidelines

### Video Selection
- ✅ **5-10 minutes max** - keeps engagement high
- ✅ **Clear explanations** - no jargon-heavy content
- ✅ **Hindi or bilingual** - accessible for all students
- ❌ **Long lectures** - students lose interest
- ❌ **Advanced content** - match to target audience level

### Assessment Design
- **Formative** (daily): Quick quizzes, practice exercises, short tasks
- **Summative** (end): Projects, presentations, comprehensive tests
- Keep assessments **practical and hands-on**

### Flexibility
- Curriculum should accommodate different learning speeds
- Include alternative resources for advanced/struggling students
- Build in buffer days for revision or catch-up

---

## Example Interaction

**User:** "Design curriculum for a POD teaching AI tools to Class 8-10 students"

**Response:**

### Phase 1: Requirements Gathering
I'll need some details to design this curriculum:

1. **POD Name:** [Which POD?]
2. **Duration:** How many weeks/months?
3. **Classes per week:** Daily? 3x/week?
4. **Previous exposure:** Have students used AI tools before?
5. **Teacher capability:** Can the teacher guide students through AI tools?
6. **Learning focus:** What's the main goal?
   - [ ] Basic AI understanding
   - [ ] Using AI for studying
   - [ ] AI for projects/creativity
   - [ ] All of the above

---

### Phase 2: Research
[Search for relevant 5-10 min YouTube videos on AI basics, ChatGPT, etc.]

---

### Phase 3-5: Curriculum Creation
[Generate sheet with 30-day curriculum covering AI basics, ChatGPT, NotebookLM, Perplexity, Grammarly, Canva AI, etc.]

---

## Folder Reference

| Resource | Link |
|----------|------|
| Curriculum Designer Folder | `https://drive.google.com/drive/folders/1upJQu-IVmZRJQsNGmJNRzq9IwL67MVL9` |
| Example Curriculum (AI Tools) | `https://docs.google.com/spreadsheets/d/1hYC2Q2KlW8dM71biC97RPSvFnxTQa-zN` |
| SOP Document | `https://docs.google.com/document/d/1Y5qetW8S4RWsTg7hycIyujgTwTCFn9VV` |

---

## Notes

- Always confirm requirements before generating full curriculum
- Save curriculum sheets in the designated folder
- Share viewable link at the end
- Document curriculum version for future reference
- Consider teacher training needs if curriculum requires new tools
