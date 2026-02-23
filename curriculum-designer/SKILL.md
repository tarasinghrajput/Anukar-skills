---
name: curriculum-designer
description: "Design customized curricula for PODs with REAL resource links. Use when user says 'Design curriculum', 'Create curriculum for POD', or 'Build learning plan'. Gathers requirements, searches YouTube for actual video URLs, and creates a structured curriculum sheet with daily objectives, assessments, and real video links."
---

# Curriculum Designer

Design customized curricula for Apni Pathshala PODs with **real YouTube video links**.

## Trigger
User message contains:
- **"Design curriculum"** → Start curriculum creation
- **"Create curriculum for [POD name]"** → Start with POD context
- **"Build learning plan"** → Start curriculum creation
- **"Curriculum for [subject/topic]"** → Start with topic context

## Target User
This skill is designed for **Madhur** (Academic Associate) who designs curricula for PODs.

## Configuration
- **YouTube API Key:** Stored in `~/.openclaw/workspace/.api_keys`
- **Output Folder:** `1upJQu-IVmZRJQsNGmJNRzq9IwL67MVL9` (Curriculum Designer)

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
9. **Teacher Training Needed** - Do teachers need any training?

#### Learning Outcomes
10. **Learning Area Focus** - Which area(s) to prioritize?
    - Digital Literacy
    - Academic Empowerment
    - Skill Development
    - Employment Readiness
11. **Specific Skills** - What specific skills should students acquire?
12. **Assessment Method** - How will learning be measured?

---

### Phase 2: Research & Find Resources (AUTOMATED)

**This phase now AUTOMATICALLY searches YouTube for real video URLs.**

#### YouTube Search Function

```bash
# Function to search YouTube for educational videos
search_youtube() {
    local query="$1"
    local api_key="AIzaSyCPcagIbbRoN5enFc0YAvt9s9KQ3_iWt1Y"
    
    # Search for videos (short duration = <4min, medium = 4-20min)
    curl -s "https://www.googleapis.com/youtube/v3/search?part=snippet&q=${query}+tutorial+hindi+beginners&type=video&maxResults=5&videoDuration=medium&key=${api_key}" | \
    python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    items = data.get('items', [])
    for item in items[:3]:
        video_id = item['id']['videoId']
        title = item['snippet']['title']
        print(f'https://youtube.com/watch?v={video_id}')
        print(f'TITLE: {title}')
except: pass
"
}
```

#### Search Queries by Topic

| Topic | Search Query |
|-------|--------------|
| Computer Basics | `computer basics tutorial hindi beginners` |
| File Management | `file folder management windows hindi` |
| Typing | `typing practice hindi tutorial` |
| Internet | `internet browser basics hindi` |
| Email | `gmail email tutorial hindi beginners` |
| Google Docs | `google docs tutorial hindi` |
| Google Sheets | `google sheets formulas hindi` |
| ChatGPT | `chatgpt tutorial hindi beginners 2024` |
| AI Tools | `ai tools for students hindi` |
| Resume | `resume writing hindi tutorial` |
| Interview Skills | `job interview tips hindi` |
| Canva | `canva tutorial hindi beginners` |
| LinkedIn | `linkedin profile create hindi` |

#### Research Process

For each curriculum topic:
1. **Search YouTube** using the API
2. **Filter results:**
   - Duration: 5-10 minutes (use `videoDuration=medium`)
   - Language: Hindi/English
   - Quality: View count, relevance
3. **Select top 2-3 videos** per topic
4. **Store URLs** with titles for the curriculum

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
- **Resources** - **REAL YouTube URLs** + tools needed

---

### Phase 4: Create Curriculum Sheet with Real URLs

**Output Format:** Google Sheet with the following columns:

| Column | Description |
|--------|-------------|
| Day | Day number (1, 2, 3...) |
| Subject | Subject area / Learning area |
| Module | Module/Topic name |
| Daily Learning Objectives | What students learn that day |
| Daily Assessment | How to assess understanding |
| YouTube Link | **REAL video URL** (5-10 min) |
| Tools Used | Required software/platforms |

---

### Phase 5: Save and Share

1. **Create the sheet** in the Curriculum Designer folder
2. **Set up columns** with headers
3. **Populate with curriculum data** including **real YouTube URLs**
4. **Get shareable link** with "Anyone with link can view"
5. **Return the link** to Madhur

---

## YouTube Search Implementation

### Bash Function for Curriculum Designer

```bash
#!/bin/bash
# search_videos.sh - Search YouTube for curriculum videos

API_KEY="AIzaSyCPcagIbbRoN5enFc0YAvt9s9KQ3_iWt1Y"

search_topic() {
    local topic="$1"
    local encoded_query=$(echo "$topic tutorial hindi beginners" | sed 's/ /+/g')
    
    curl -s "https://www.googleapis.com/youtube/v3/search?part=snippet&q=${encoded_query}&type=video&maxResults=5&videoDuration=medium&key=${API_KEY}" | \
    python3 << PYEOF
import sys, json
try:
    data = json.load(sys.stdin)
    items = data.get('items', [])
    if items:
        # Return first valid video
        video = items[0]
        video_id = video['id']['videoId']
        title = video['snippet']['title']
        print(f"https://youtube.com/watch?v={video_id}")
    else:
        print("No video found")
except:
    print("Search failed")
PYEOF
}

# Usage examples
# search_topic "computer basics"
# search_topic "google sheets formulas"
# search_topic "chatgpt for students"
```

### Python Helper for Bulk Searches

```python
#!/usr/bin/env python3
# bulk_youtube_search.py

import requests
import json

API_KEY = "AIzaSyCPcagIbbRoN5enFc0YAvt9s9KQ3_iWt1Y"

def search_videos(query, max_results=3):
    """Search YouTube for educational videos"""
    url = "https://www.googleapis.com/youtube/v3/search"
    params = {
        'part': 'snippet',
        'q': f'{query} tutorial hindi beginners',
        'type': 'video',
        'maxResults': max_results,
        'videoDuration': 'medium',  # 4-20 minutes
        'key': API_KEY
    }
    
    response = requests.get(url, params=params)
    data = response.json()
    
    videos = []
    for item in data.get('items', []):
        videos.append({
            'url': f"https://youtube.com/watch?v={item['id']['videoId']}",
            'title': item['snippet']['title'],
            'channel': item['snippet']['channelTitle']
        })
    
    return videos

# Curriculum topics to search
TOPICS = [
    "computer basics",
    "typing practice",
    "internet browser",
    "gmail email",
    "google docs",
    "google sheets",
    "chatgpt",
    "grammarly",
    "canva design",
    "resume writing",
    "interview tips",
    "linkedin profile"
]

# Search all topics
for topic in TOPICS:
    videos = search_videos(topic)
    if videos:
        print(f"{topic}: {videos[0]['url']}")
```

---

## Important Guidelines

### Video Selection Criteria
- ✅ **5-10 minutes max** - keeps engagement high
- ✅ **Clear explanations** - no jargon-heavy content
- ✅ **Hindi or bilingual** - accessible for all students
- ✅ **Recent content** - prefer 2023+ videos
- ❌ **Long lectures** - students lose interest
- ❌ **Advanced content** - match to target audience level

### Assessment Design
- **Formative** (daily): Quick quizzes, practice exercises, short tasks
- **Summative** (end): Projects, presentations, comprehensive tests
- Keep assessments **practical and hands-on**

### API Usage
- **Quota:** 10,000 units/day
- **Each search:** ~100 units
- **Max searches per curriculum:** ~60 (one per day for 60-day curriculum)
- **Stay within limits:** Batch searches, cache results

---

## Example Output

### Before (Old)
```
| YouTube Link |
|--------------|
| Search: 'Windows basics tutorial Hindi for beginners' |
```

### After (New)
```
| YouTube Link |
|--------------|
| https://youtube.com/watch?v=4lraNH0jLb8 |
```

---

## Folder Reference

| Resource | Link |
|----------|------|
| Curriculum Designer Folder | `https://drive.google.com/drive/folders/1upJQu-IVmZRJQsNGmJNRzq9IwL67MVL9` |
| Example Curriculum (AI Tools) | `https://docs.google.com/spreadsheets/d/1hYC2Q2KlW8dM71biC97RPSvFnxTQa-zN` |
| SOP Document | `https://docs.google.com/document/d/1Y5qetW8S4RWsTg7hycIyujgTwTCFn9VV` |

---

## Notes

- Always search for REAL video URLs before creating curriculum
- Save curriculum sheets in the designated folder
- Share viewable link at the end
- Cache video searches to avoid API quota limits
- Consider teacher training needs if curriculum requires new tools
