# Researcher Task: Curriculum Research

## Context
You are researching resources for a curriculum. Your output will be used to create a Google Sheet.

## User Requirements
- **POD Type:** [P0/P1/P2/P3]
- **Focus Area:** [specified]
- **Content Types:** [specified]
- **Duration:** [specified]
- **Specific Topics:** [if any]

## Your Tasks

### 1. Find Quality Resources
- Search for relevant learning materials
- Verify resource quality and accessibility
- Check if resources match the POD level
- Prefer free resources unless specified

### 2. Organize into Clusters
Group resources into 4-6 logical clusters:

- **Cluster 1: Introduction/Fundamentals**
- **Cluster 2: Core Concepts**
- **Cluster 3: Intermediate Topics**
- **Cluster 4: Advanced/Practice**
- **Cluster 5: Projects** (if applicable)

### 3. For Each Resource, Collect:
- Title
- URL/Link
- Content type (video/reading/exercise/project)
- Estimated duration
- Topics covered
- Difficulty level

### 4. Output Format

Return a JSON structure:

```json
{
  "curriculumId": "CUR-2026-02-22-001",
  "fileName": "Curriculum_P0_WebDevelopment_2026-02-22",
  "targetPODType": "P0",
  "focusArea": "Web Development",
  "duration": "1 month",
  "clusters": [
    {
      "name": "HTML Fundamentals",
      "description": "Basic HTML concepts",
      "resources": [
        {
          "title": "HTML Full Course - Beginner to Pro",
          "link": "https://youtube.com/...",
          "contentType": "video",
          "topics": ["HTML tags", "elements", "attributes"],
          "duration": "2 hours",
          "difficulty": "beginner"
        }
      ]
    }
  ],
  "coveredTopics": ["HTML", "CSS", "JavaScript basics"],
  "totalResources": 15,
  "owner": "Anukar",
  "createdAt": "2026-02-22"
}
```

### 5. Quality Criteria
- Resources must be accessible (verify links)
- Content must match the POD level
- Prefer well-known platforms (freeCodeCamp, YouTube, MDN, etc.)
- Include variety of content types
- Check for recency (prefer resources from last 2 years)

### 6. Save Output
Save to: /home/aptest/.openclaw/workspace/curricula/[curriculumId].json

### 7. Dashboard Logging
```bash
cd /home/aptest/.openclaw/workspace/Anukar-Dashboard/backend
node agentCli.js start researcher "Curriculum Research" "[Focus Area] for [POD Type]"
node agentCli.js complete researcher "[TASK_ID]" "Curriculum Research" "Found X resources across Y clusters" "curricula/[curriculumId].json" "research"
```
