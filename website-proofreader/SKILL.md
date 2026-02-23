---
name: website-proofreader
description: "Daily website grammar proofreader. Crawls all pages of configured websites, checks for grammatical errors using AI, and emails a detailed report. Runs automatically at 6 AM IST via cron. Use 'run proofreader' to check manually or 'add website proofreader' to add new sites."
---

# Website Proofreader

Automated daily grammar checker for Apni Pathshala websites.

## Trigger
- **"run proofreader"** → Run grammar check now
- **"add website proofreader [url]"** → Add new website to check
- **"proofreader report"** → View last report
- **Cron: 6 AM IST daily** → Automatic run

---

## Configuration

### Websites to Check
Stored in `~/clawd/website-proofreader/sites.txt`:
```
https://apnipathshala.org
https://chaloseekhe.org
https://apnapc.com
```

### Email Recipients
- apnipathshalaorg@gmail.com
- tarasinghrajput7261@gmail.com

### Schedule
- **Cron:** 0 0:30 * * * (00:30 UTC = 6:00 AM IST)

---

## Workflow

### Step 1: Crawl Website
For each site in the list:
1. Get sitemap.xml if available
2. Crawl all linked pages from homepage
3. Extract text content (ignore code, scripts, styles)
4. Store page URL + text for analysis

### Step 2: Grammar Check
For each page's text:
1. Split into sentences
2. Check each sentence for grammar issues using AI
3. Identify: spelling errors, grammar mistakes, awkward phrasing
4. Capture context (surrounding text)

### Step 3: Generate Report
Create structured report:
```
# Grammar Report - [Date]

## Summary
- Total Pages Checked: X
- Total Issues Found: Y
- By Website:
  - apnipathshala.org: A issues
  - chaloseekhe.org: B issues
  - apnapc.com: C issues

## Issues by Page

### [Page Title]
**URL:** https://...
**Issues Found:** N

| # | Error Type | Original Text | Suggested Fix | Context |
|---|------------|---------------|---------------|---------|
| 1 | Spelling | "teh" | "the" | "...went to teh store..." |
| 2 | Grammar | "He go to school" | "He goes to school" | "...everyday He go to..." |

---
```

### Step 4: Email Report
Send to configured recipients with:
- Subject: `Website Grammar Report - [Date]`
- Body: Full report
- Attach: CSV export of all issues

---

## Technical Implementation

### Crawler Script
```bash
#!/bin/bash
# crawl-site.sh - Extract all text from website pages

SITE=$1
OUTPUT_DIR=$2

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Get sitemap URLs if available
SITEMAP_URLS=$(curl -s "${SITE}/sitemap.xml" | grep -oP '(?<=<loc>)[^<]+' | head -100)

if [ -n "$SITEMAP_URLS" ]; then
    echo "$SITEMAP_URLS" > "${OUTPUT_DIR}/urls.txt"
else
    # If no sitemap, crawl from homepage
    wget --spider -r -l 3 -nd -H -A html,htm "${SITE}" 2>&1 | grep -oP 'https?://[^ ]+' | sort -u > "${OUTPUT_DIR}/urls.txt"
fi

# Extract text from each URL
while read -r url; do
    # Get page content and extract text
    curl -s "$url" | \
        sed 's/<script[^>]*>.*<\/script>//gi' | \
        sed 's/<style[^>]*>.*<\/style>//gi' | \
        sed 's/<[^>]*>//g' | \
        sed 's/&nbsp;/ /g' | \
        sed 's/&amp;/\&/g' | \
        tr -s ' \n' ' ' > "${OUTPUT_DIR}/$(echo $url | md5sum | cut -d' ' -f1).txt"
    
    # Store URL mapping
    echo "${url},$(echo $url | md5sum | cut -d' ' -f1).txt" >> "${OUTPUT_DIR}/url_map.csv"
done < "${OUTPUT_DIR}/urls.txt"
```

### Grammar Check with AI
For each extracted text file:
1. Read text content
2. Send to AI with grammar checking prompt
3. Parse response for issues
4. Map back to page URL

**AI Prompt for Grammar Checking:**
```
You are a grammar checker. Analyze the following text and identify ALL grammatical errors, spelling mistakes, and awkward phrasing.

For each issue found, provide:
1. Error type (Spelling/Grammar/Punctuation/Style)
2. The original text with error
3. The corrected version
4. Brief explanation

Text to check:
[PAGE CONTENT]

Output format (JSON):
{
  "issues": [
    {
      "type": "Spelling",
      "original": "teh",
      "corrected": "the",
      "context": "...went to teh store...",
      "explanation": "Common typo"
    }
  ]
}
```

---

## Cron Setup

```bash
# Add to OpenClaw cron
openclaw cron add --name "website-proofreader" --schedule "0 0:30 * * *" --command "run proofreader"
```

Or manually via crontab:
```
30 0 * * * /home/aptest/.openclaw/workspace/skills/website-proofreader/run-proofreader.sh
```

---

## File Structure
```
~/clawd/website-proofreader/
├── sites.txt           # List of websites to check
├── recipients.txt      # Email recipients
├── cache/              # Cached page content
├── reports/            # Historical reports
│   └── YYYY-MM-DD/
│       ├── report.md
│       └── issues.csv
└── last_report.json    # Summary of last run
```

---

## Commands

### Add Website
```bash
echo "https://newsite.com" >> ~/clawd/website-proofreader/sites.txt
```

### Remove Website
```bash
sed -i '/newsite.com/d' ~/clawd/website-proofreader/sites.txt
```

### View Sites
```bash
cat ~/clawd/website-proofreader/sites.txt
```

### Manual Run
```bash
~/clawd/website-proofreader/run-proofreader.sh
```

---

## Notes

- **Rate Limiting:** 2 second delay between page requests to avoid blocking
- **Cache:** Pages cached for 24 hours to avoid re-crawling
- **Max Pages:** 100 pages per site (configurable)
- **Timeout:** 30 second timeout per page
- **User Agent:** Identify as "ApniPathshala-GrammarBot/1.0"

---

## Accuracy Measures

1. **Multi-pass checking:** Each sentence checked independently
2. **Context awareness:** AI considers surrounding text
3. **False positive filtering:** Ignore common web terms (URLs, emails, code)
4. **Confidence threshold:** Only report issues with high confidence
5. **Duplicate removal:** Same error on multiple pages counted once

---

## Example Report

```
# Website Grammar Report - 2026-02-23

## Summary
- Total Pages Checked: 47
- Total Issues Found: 12
- Critical: 2 | Major: 5 | Minor: 5

## By Website
- apnipathshala.org: 5 issues (23 pages)
- chaloseekhe.org: 4 issues (15 pages)
- apnapc.com: 3 issues (9 pages)

## Top Issues

### 1. apnipathshala.org/about
**Issue:** Missing article
❌ "He is student at Apni Pathshala"
✅ "He is a student at Apni Pathshala"

### 2. chaloseekhe.org/contact
**Issue:** Subject-verb agreement
❌ "Students learns digital skills"
✅ "Students learn digital skills"

---
Report generated by Anukar 🐆
```
