---
name: gh-issue-create
description: Create well-formatted GitHub issues from a short description. Auto-classifies type and priority, assigns labels, and formats the body with Description, Reproduction Steps, and Expected Behaviour sections.
---

# gh-issue-create

Create well-formatted GitHub issues from a short description. Auto-detects whether it's a bug or feature request, assigns priority, and formats the body with consistent sections.

## Usage

```bash
/gh-issue-create <alias> "<short description>" [--a <assignee>]                           # quick issue
/gh-issue-create <alias> --title "..." --body "..." [--a <assignee>]                      # full control
/gh-issue-create --repo owner/repo --path /local/path "<description>" [--a <assignee>]    # ad-hoc repo
```

Issue numbers come first, flags after.

## Repository Configuration

Uses the same repo aliases from `~/.claude/skills/gh-issue-resolver/repos.json`:

```json
{
  "pms": "/mnt/c/Users/72619/OneDrive/Documents/React Apps/apni-pathshala-pms",
  "prerna": "/mnt/c/Users/72619/OneDrive/Documents/React Apps/sss",
  "apna-dashboard": "/mnt/c/Users/72619/OneDrive/Documents/ApniPathshala/apna-dashboard",
  "em-indian": "/mnt/c/Users/72619/OneDrive/Documents/React Apps/empowered-indian"
}
```

## How it works

### Step 1 — Resolve repo and working directory

1. Read `~/.claude/skills/gh-issue-resolver/repos.json`.
2. If the first positional argument matches an alias, use that alias's path.
3. Extract `<REPO>` (owner/name) from `git -C <WORKDIR> remote get-url origin`.
4. If `--repo` is passed, override `<REPO>` with the explicit value.
5. If `--path` is passed, override `<WORKDIR>` with the explicit value.

### Step 2 — Interpret the description

- If `--title` is provided, use it as the title.
- If the user provides a short description as a positional argument (no `--title`), use it directly as the title.
- If `--body` is provided, use it verbatim in the body.
- If no `--body`, generate the full issue body from the description with these sections:

```markdown
# Description
[2-4 sentences explaining the issue]

# Reproduction Steps
1. [Step one]
2. [Step two]
3. [Step three]

# Expected Behaviour
- [Expected outcome]
```

### Step 3 — Auto-classify type and priority

**Type detection:**

| Content signals | Label |
|----------------|-------|
| Bug, error, crash, broken, not working, wrong, fix, typo, regression | `bug` |
| Feature, add, request, would like, new, enhancement, suggestion | `enhancement` |

**Priority detection:**

| Signal | Priority |
|--------|----------|
| Data loss, security, crash, broken auth, payment, privacy | **P0** (blocker) |
| Core feature broken, major UX blocked, no workaround | **P1** (high) |
| Feature partially broken, moderate impact, workaround exists | **P2** (medium) |
| Cosmetic, nice-to-have, edge case, minor, documentation | **P3** (low) |

### Step 4 — Create the issue

```bash
gh issue create \
  --repo <REPO> \
  --title "<TITLE>" \
  --body "<BODY>" \
  --label "<TYPE>,<PRIORITY>" \
  --assignee "<ASSIGNEE>"
```

- **Assignee**: `tarasinghrajput` by default. Override with `--a <username>`. Use `--a "@me"` for self-assign.
- **Graceful degradation**: If `--label` or `--assignee` fails (labels don't exist, or user isn't a collaborator), retry without the failing flag and report which was skipped.

### Step 5 — Report

Output the created issue URL and a summary:

> Created issue #42: Fix login button on mobile
> https://github.com/roshanasingh4/apni-pathshala-pms/issues/42
> Labels: bug, P1
> Assignee: tarasinghrajput

If labels or assignee were skipped, mention it:

> ⚠️ Could not assign monalisa — they may not be a collaborator on this repo.

### Step 6 — Log issue to Google Sheet

Append the newly created issue as a new row **within** the **Production** sheet's table using the helper script at `~/.claude/skills/gh-issue-create/append-issue.sh`.

The script handles everything: reading column A for the next Sr. no, finding the table boundary, inserting a dimension to expand the table, writing the row, and verifying it. Previously the skill used `gws sheets +append` which always wrote outside the table.

**Project name mapping (for column D):**

| Alias | Project Name |
|-------|-------------|
| `pms` | `PMS` |
| `apna-dashboard` | `Apna Dashboard` |
| `prerna` | `Prerna` |
| `em-indian` | `Empowered Indian` |

**Column mapping:**

| Col | Header | Value for new issue |
|-----|--------|-------------------|
| A | Sr. no | Auto-incremented by the script: finds max `PMS-TSK-NNN`, increments, zero-padded to 3 digits |
| B | Description | Issue title (passed to script) |
| C | Assignee Name | `Tara Singh Kharwad` |
| D | Project | Project name from alias mapping table above |
| E | Date Submitted | Today's date in `DD/MM/YYYY` (IST) |
| F | Status | `New` |
| G | Task type | `Issue` if label is `bug`, `Feature` if label is `enhancement` |
| H | Priority | Map: P0 → `Critical`, P1 → `High`, P2 → `Medium`, P3 → `Low` |
| I | Assigned To | `tarasinghrajput7261@gmail.com` |
| J | Resolution Notes | GitHub issue URL |

**Command:**

```bash
bash ~/.claude/skills/gh-issue-create/append-issue.sh \
  -p "<PROJECT>" \
  -d "<TITLE>" \
  -t "<TASK_TYPE>" \
  -r "<PRIORITY>" \
  -u "<ISSUE_URL>"
```

- `<PROJECT>` — resolved from the alias mapping above.
- `<TITLE>` — the issue title (from Step 2).
- `<TASK_TYPE>` — `Issue` if the detected label is `bug`, `Feature` if `enhancement`.
- `<PRIORITY>` — mapped from the auto-classified priority: P0→Critical, P1→High, P2→Medium, P3→Low.
- `<ISSUE_URL>` — constructed as `https://github.com/<REPO>/issues/<ISSUE_NUMBER>` captured from Step 4.

- **Graceful degradation**: If the script is missing, `gws` is not installed, the sheet is inaccessible, or the append fails, warn the user but do **not** fail the issue creation. The issue was already created successfully in Step 4.

## Body expansion examples

**Short prompt:**
```
/gh-issue-create pms "Login button not working on mobile devices"
```

**Expands to title:** "Login button not working on mobile devices"

**Expands to body:**
```markdown
# Description
The login button on mobile devices is unresponsive after clicking. The issue occurs on both Android and iOS browsers. This blocks all users from accessing the application on mobile.

# Reproduction Steps
1. Open the application on a mobile device
2. Navigate to the login page
3. Tap the login button
4. Observe that no loading state appears and the user is not logged in

# Expected Behaviour
- The login button should respond to taps on mobile devices
- A loading state should display while authentication is in progress
- Users should be redirected to the dashboard after successful login
```

## Flags

| Flag | Required | Default | Purpose |
|------|----------|---------|---------|
| `<alias>` | Yes* | — | Alias from repos.json (*or use `--repo` + `--path`) |
| `<description>` | Yes (unless `--title`) | — | Short issue description or title |
| `--title` | No | From description | Explicit title (overrides positional description) |
| `--body` | No | Generated from description | Explicit body text |
| `--a <username>` | No | `tarasinghrajput` | GitHub username to assign |
| `--repo owner/repo` | No | — | Direct repo spec (for ad-hoc repos) |
| `--path /path` | No | — | Working directory (required with `--repo`) |

## Important Notes

- If both `<description>` and `--title` are provided, `--title` wins for the title and the positional text is still used to generate the body.
- Labels (`bug`/`enhancement` + priority) and assignee are best-effort. If the repo doesn't support them, the issue is still created and you are notified.
- The body is always formatted with the three standard sections: Description, Reproduction Steps, Expected Behaviour.
- If the user provides `--body`, use it exactly as given.
