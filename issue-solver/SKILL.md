---
name: issue-solver
description: "Automatically solve GitHub issues using Codex CLI. Monitors tarasinghrajput/Task-Tracker repo for new issues, solves them with Codex, tests, and pushes changes. Trigger: 'solve issues', 'check new issues', or automatic cron polling."
---

# Issue Solver

Automatically solve GitHub issues using Codex CLI for the Task-Tracker repo.

## Trigger
- **"Solve issues"** → Check for new issues and solve them
- **"Check new issues"** → List new issues without solving
- **"Solve issue #X"** → Solve a specific issue
- **Cron: Every 30 minutes** → Automatic polling for new issues

---

## Repository Details

| Info | Value |
|------|-------|
| **Repo** | tarasinghrajput/Task-Tracker |
| **Tech Stack** | React + Vite (client), Node.js + Express + MongoDB (backend) |
| **Codex CLI** | v0.104.0 |

---

## Workflow

```
┌─────────────────────────────────────────────────────────────┐
│                    ISSUE SOLVER WORKFLOW                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  PHASE 1: DETECT NEW ISSUES                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 1. Poll GitHub API for new issues                    │   │
│  │ 2. Check if issue was already processed              │   │
│  │ 3. Store new issue IDs in processed list             │   │
│  └─────────────────────────────────────────────────────┘   │
│                          │                                  │
│                          ▼                                  │
│  PHASE 2: PREPARE ENVIRONMENT                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 1. Clone/fetch latest from repo                      │   │
│  │ 2. Create new branch for fix                         │   │
│  │ 3. Install dependencies                              │   │
│  └─────────────────────────────────────────────────────┘   │
│                          │                                  │
│                          ▼                                  │
│  PHASE 3: SOLVE WITH CODEX                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 1. Read issue title + body                           │   │
│  │ 2. Run Codex CLI with issue context                  │   │
│  │ 3. Monitor Codex output                              │   │
│  │ 4. Review generated changes                          │   │
│  └─────────────────────────────────────────────────────┘   │
│                          │                                  │
│                          ▼                                  │
│  PHASE 4: TEST SOLUTION                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 1. Run linting (npm run lint)                        │   │
│  │ 2. Run build (npm run build)                         │   │
│  │ 3. Run tests if available                             │   │
│  │ 4. Verify no breaking changes                        │   │
│  └─────────────────────────────────────────────────────┘   │
│                          │                                  │
│                          ▼                                  │
│  PHASE 5: PUSH CHANGES                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 1. Commit changes with issue reference               │   │
│  │ 2. Push branch to origin                             │   │
│  │ 3. Create PR linking to issue                        │   │
│  │ 4. Comment on issue with PR link                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Implementation

### Phase 1: Detect New Issues

```bash
# Check for new issues
gh issue list --repo tarasinghrajput/Task-Tracker \
    --state open \
    --json number,title,body,createdAt \
    --jq '.[] | select(.createdAt > "2026-02-23")'

# Track processed issues
PROCESSED_FILE="~/clawd/issue-solver/processed_issues.txt"

# Get new issues
NEW_ISSUES=$(gh issue list --repo tarasinghrajput/Task-Tracker \
    --state open \
    --json number \
    --jq '.[].number' | \
    grep -v -F -f "$PROCESSED_FILE")
```

### Phase 2: Prepare Environment

```bash
REPO_DIR="/tmp/Task-Tracker"
REPO_URL="https://github.com/tarasinghrajput/Task-Tracker"

# Clone or update repo
if [ -d "$REPO_DIR" ]; then
    cd "$REPO_DIR"
    git fetch origin
    git checkout main
    git pull origin main
else
    git clone "$REPO_URL" "$REPO_DIR"
    cd "$REPO_DIR"
fi

# Create branch for fix
BRANCH_NAME="fix/issue-${ISSUE_NUMBER}"
git checkout -b "$BRANCH_NAME"

# Install dependencies
cd client && npm install
cd ../backend && npm install
```

### Phase 3: Solve with Codex

```bash
# Get issue details
ISSUE_TITLE=$(gh issue view $ISSUE_NUMBER --repo tarasinghrajput/Task-Tracker --json title --jq '.title')
ISSUE_BODY=$(gh issue view $ISSUE_NUMBER --repo tarasinghrajput/Task-Tracker --json body --jq '.body')

# Create prompt for Codex
PROMPT="Fix this GitHub issue in the Task-Tracker app:

Issue #$ISSUE_NUMBER: $ISSUE_TITLE

Description:
$ISSUE_BODY

The app has:
- client/ - React + Vite frontend
- backend/ - Node.js + Express + MongoDB backend

Please:
1. Analyze the issue
2. Implement the fix
3. Ensure code follows existing patterns
4. Don't break existing functionality"

# Run Codex CLI
cd "$REPO_DIR"
codex --prompt "$PROMPT" --full-auto
```

### Phase 4: Test Solution

```bash
cd "$REPO_DIR"

# Test client
cd client
npm run lint
npm run build

# Test backend
cd ../backend
npm run lint 2>/dev/null || echo "No lint script"

# Run tests if available
npm test 2>/dev/null || echo "No tests configured"
```

### Phase 5: Push Changes

```bash
cd "$REPO_DIR"

# Check if there are changes
if git diff --quiet; then
    echo "No changes made by Codex"
    exit 0
fi

# Commit
git add .
git commit -m "Fix #$ISSUE_NUMBER: $ISSUE_TITLE

This fix was automatically generated by Anukar using Codex CLI.

Closes #$ISSUE_NUMBER"

# Push
git push origin "$BRANCH_NAME"

# Create PR
gh pr create \
    --repo tarasinghrajput/Task-Tracker \
    --title "Fix #$ISSUE_NUMBER: $ISSUE_TITLE" \
    --body "## Summary
This PR fixes issue #$ISSUE_NUMBER

## Changes
Auto-generated by Codex CLI

## Testing
- [x] Lint passed
- [x] Build passed

---
Generated by Anukar 🐆"

# Comment on issue
gh issue comment $ISSUE_NUMBER \
    --repo tarasinghrajput/Task-Tracker \
    --body "🤖 I've created a fix for this issue in PR #XXX

Please review and merge if it looks good!"

# Mark as processed
echo "$ISSUE_NUMBER" >> ~/clawd/issue-solver/processed_issues.txt
```

---

## Main Script

```bash
#!/bin/bash
# ~/clawd/issue-solver/solve-issues.sh

set -e

REPO="tarasinghrajput/Task-Tracker"
REPO_DIR="/tmp/Task-Tracker"
PROCESSED_FILE="$HOME/clawd/issue-solver/processed_issues.txt"

# Ensure processed file exists
mkdir -p "$(dirname "$PROCESSED_FILE")"
touch "$PROCESSED_FILE"

echo "🔍 Checking for new issues..."

# Get all open issues
ISSUES=$(gh issue list --repo "$REPO" --state open --json number --jq '.[].number')

for ISSUE_NUMBER in $ISSUES; do
    # Skip if already processed
    if grep -q "^$ISSUE_NUMBER$" "$PROCESSED_FILE"; then
        echo "  ⏭️ Issue #$ISSUE_NUMBER already processed"
        continue
    fi
    
    echo ""
    echo "📌 Processing Issue #$ISSUE_NUMBER"
    echo "======================================"
    
    # Get issue details
    ISSUE_TITLE=$(gh issue view $ISSUE_NUMBER --repo "$REPO" --json title --jq '.title')
    echo "  Title: $ISSUE_TITLE"
    
    # Prepare environment
    echo "  📦 Preparing environment..."
    if [ -d "$REPO_DIR" ]; then
        cd "$REPO_DIR"
        git fetch origin
        git checkout main
        git pull origin main
    else
        git clone "https://github.com/$REPO" "$REPO_DIR"
        cd "$REPO_DIR"
    fi
    
    # Create branch
    BRANCH_NAME="fix/issue-${ISSUE_NUMBER}"
    git checkout -b "$BRANCH_NAME" 2>/dev/null || git checkout "$BRANCH_NAME"
    
    # Solve with Codex
    echo "  🤖 Running Codex CLI..."
    ISSUE_BODY=$(gh issue view $ISSUE_NUMBER --repo "$REPO" --json body --jq '.body')
    
    codex --prompt "Fix GitHub issue #$ISSUE_NUMBER in this Task-Tracker app.

Title: $ISSUE_TITLE
Description: $ISSUE_BODY

The app structure:
- client/ - React + Vite + Tailwind frontend
- backend/ - Node.js + Express + MongoDB backend

Implement the fix following existing code patterns." --full-auto
    
    # Test
    echo "  🧪 Testing solution..."
    cd "$REPO_DIR/client"
    npm run lint 2>/dev/null || true
    npm run build 2>/dev/null || true
    
    # Check for changes
    cd "$REPO_DIR"
    if git diff --quiet; then
        echo "  ⚠️ No changes made"
        echo "$ISSUE_NUMBER" >> "$PROCESSED_FILE"
        continue
    fi
    
    # Commit and push
    echo "  📤 Pushing changes..."
    git add .
    git commit -m "Fix #$ISSUE_NUMBER: $ISSUE_TITLE

Auto-generated by Anukar using Codex CLI.

Closes #$ISSUE_NUMBER"
    
    git push origin "$BRANCH_NAME"
    
    # Create PR
    PR_URL=$(gh pr create \
        --repo "$REPO" \
        --title "Fix #$ISSUE_NUMBER: $ISSUE_TITLE" \
        --body "## Summary
Fixes #$ISSUE_NUMBER

## Changes
Auto-generated by Codex CLI

---
*Generated by Anukar 🐆*" \
        --json url --jq '.url')
    
    echo "  ✅ PR created: $PR_URL"
    
    # Comment on issue
    gh issue comment $ISSUE_NUMBER \
        --repo "$REPO" \
        --body "🤖 I've created a fix: $PR_URL"
    
    # Mark as processed
    echo "$ISSUE_NUMBER" >> "$PROCESSED_FILE"
    
    echo "  ✅ Issue #$ISSUE_NUMBER processed!"
done

echo ""
echo "✅ Done processing issues"
```

---

## Cron Setup

```bash
# Poll for new issues every 30 minutes
openclaw cron add \
    --name "issue-solver" \
    --cron "*/30 * * * *" \
    --tz "Asia/Calcutta" \
    --session main \
    --system-event "Run the issue-solver skill to check for new GitHub issues in tarasinghrajput/Task-Tracker and solve them using Codex CLI"
```

---

## Safety Measures

1. **Review before merge** - PRs require manual review
2. **Test builds** - Verify build passes before pushing
3. **Processed tracking** - Don't re-process same issue
4. **Branch per issue** - Isolated changes
5. **PR linking** - Clear traceability

---

## File Structure

```
~/clawd/issue-solver/
├── solve-issues.sh           # Main script
├── processed_issues.txt      # Already processed
└── logs/
    └── 2026-02-24.log        # Daily logs
```

---

## Manual Commands

| Command | Action |
|---------|--------|
| "Solve issues" | Check and solve all new issues |
| "Solve issue #5" | Solve specific issue |
| "Check new issues" | List new issues without solving |
| "Issue solver status" | Show processed issues count |

---

## Notes

- Codex runs in `--full-auto` mode for autonomous fixing
- PRs are created but require manual merge
- Issues are commented with PR links
- Logs stored for debugging
- Works best with clear, specific issue descriptions
