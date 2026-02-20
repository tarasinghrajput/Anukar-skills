# Anukar Skills

Custom agent skills for [Anukar](https://github.com/TaraSinghKharwad/Anukar) - an AI executive assistant powered by OpenClaw.

## Skills Overview

| Skill | Description |
|-------|-------------|
| **[comms-agent](./comms-agent)** | Communications agent for drafting emails, social posts, documentation, and content creation |
| **[devops-agent](./devops-agent)** | DevOps agent for GitHub operations, CI/CD monitoring, repo health checks, and infrastructure management |
| **[researcher-agent](./researcher-agent)** | Research agent for intel gathering, deep dives, competitor analysis, and market research |
| **[linkedin-writer](./linkedin-writer)** | Writes LinkedIn posts that sound like a real person, not a content mill |
| **[tweet-writer](./tweet-writer)** | Write viral, persuasive, engaging tweets and threads using proven formulas and X algorithm optimization |
| **[social-draft](./social-draft)** | Draft Twitter and LinkedIn posts in one go - combines tweet-writer and linkedin-writer for platform-optimized content |
| **[pms-task](./pms-task)** | Create PMS tasks (bugs/features) on GitHub and sync to Google Sheets for project management |
| **[gog](./gog)** | Google Workspace CLI for Gmail, Calendar, Drive, Contacts, Sheets, and Docs |

## Installation

Each skill is self-contained in its own directory with a `SKILL.md` file. To use these skills:

1. Copy the desired skill folder to your OpenClaw workspace skills directory:
   ```bash
   cp -r <skill-name> ~/.openclaw/workspace/skills/
   ```

2. The skill will be automatically available to your OpenClaw agent.

## Skill Details

### 🤝 Comms Agent
Handles all communications - emails, social media, documentation, summaries. Perfect for drafting content that needs review before publishing.

### 🛠️ DevOps Agent
GitHub operations, CI/CD monitoring, repo health checks. Keeps your infrastructure running smoothly.

### 🔍 Researcher Agent
Deep research, competitor analysis, market research. Gathers intel and provides structured insights.

### ✍️ LinkedIn Writer
Crafts authentic LinkedIn posts - no corporate buzzwords, just real human content.

### 🐦 Tweet Writer
Creates engaging tweets and threads using viral formulas and X algorithm optimization.

### 📱 Social Draft
One-shot social media drafts for both Twitter and LinkedIn announcements.

### 📋 PMS Task
Integrates GitHub Issues with Google Sheets for project management tracking.

### 🎮 Gog
CLI for Google Workspace - Gmail, Calendar, Drive, and more.

---

Built with ❤️ for [Anukar](https://github.com/TaraSinghKharwad/Anukar)
