---
name: gh-issue-resolver
description: Resolve GitHub issues across multiple repositories. Fetches issues, analyzes complexity, spawns Volt sub-agents to implement fixes, pushes branches, and optionally creates PRs.
---

# gh-issue-resolver

Pipeline to fetch GitHub issues from any configured repository, analyze complexity, spawn the right Volt sub-agents to implement fixes, then push and create PRs.

Supports **multiple issue numbers** — each gets its own branch and PR. Work runs in parallel for speed; git pushes are sequential with cumulative rebase to avoid sibling-branch merge conflicts.

Also supports **`--resolve-codex` mode** where positional arguments are treated as **PR numbers** instead of issue numbers. In this mode, the skill fetches unresolved code review comment threads from the specified PRs and creates fix tasks for each unresolved thread.

## Usage

```bash
/gh-issue-resolver <alias> <issue-numbers...> [flags]                                  # configured repo
/gh-issue-resolver --repo owner/repo --path /local/path <issues...> [flags]            # ad-hoc repo
/gh-issue-resolver <alias> <pr-numbers...> --resolve-codex [flags]                     # resolve codex reviews (PR numbers)
/gh-issue-resolver <alias> <pr-numbers...> --resolve-codex --pr [flags]                # resolve codex + create fix PRs
```

## Repository Configuration

Configure repo aliases in `~/.claude/skills/gh-issue-resolver/repos.json`:

```json
{
  "pms": "/mnt/c/Users/72619/OneDrive/Documents/React Apps/apni-pathshala-pms",
  "prerna": "/mnt/c/Users/72619/OneDrive/Documents/React Apps/sss",
  "apna-dashboard": "/mnt/c/Users/72619/OneDrive/Documents/ApniPathshala/apna-dashboard",
  "em-indian": "/mnt/c/Users/72619/OneDrive/Documents/React Apps/empowered-indian"
}
```

The alias maps to a local path. The GitHub `owner/repo` is auto-detected from the git remote. Add more aliases as needed.

## Flags

### Repo

- `--repo owner/repo`: Specify GitHub repo directly (for ad-hoc repos not in config).
- `--path /absolute/path`: Specify working directory directly (required with `--repo`).

### Reasoning

- `--r-low`: Set reasoning effort to **low** for ALL issues.
- `--r-mid`: Set reasoning effort to **medium** for ALL issues.
- `--r-high`: Set reasoning effort to **high** for ALL issues.
- `--r-xhigh`: Set reasoning effort to **extra high** for ALL issues.

> If more than one reasoning flag is passed, the **last one** takes precedence. If no flag is provided, auto-detect per issue based on labels and content.

### Model

- `--m-flash`: Switch model to `mimo-v2.5`.
- `--m-pro`: Switch model to `mimo-v2.5-pro`.

> If both are passed, the **last one** takes precedence. The original model is restored after all fixes are pushed.

### Other

- `--pr`: Create a Pull Request for each successful fix.
- `--no-comment`: Skip posting comments on issues.
- `--resolve-codex`: **Codex review resolution mode.** Instead of fetching GitHub issues, treat positional arguments as **PR numbers**. Fetch unresolved code review comment threads from those PRs, spawn fix agents per unresolved thread, apply fixes, and push to new branches.

### Codex Mode Behaviour

When `--resolve-codex` is active:

- Each positional argument is treated as a **PR number**, not an issue number.
- `--no-comment` has no effect (no issues to comment on).
- `--pr` creates separate fix PRs targeting the same base branch as the original PR.
- Branch naming: `fix/pr-<PR_NUMBER>-<thread-index>` (e.g., `fix/pr-42-0`, `fix/pr-42-1`).
- Comments on the original PR are posted to notify that a fix branch has been created for the unresolved thread.

### Defaults

If no flags are provided:
- **Reasoning**: auto-detect per issue, or `--r-mid` if auto-detect is not feasible
- **Model**: `--m-flash` (mimo-v2.5)

## How it works

### Step 0 — Resolve repo and working directory

Parse arguments to determine `<REPO>`, `<WORKDIR>`, and `<BASE_BRANCH>` (default: `main`):

1. If the first positional argument is a configured alias in `repos.json`, use that alias's path as `<WORKDIR>`.
2. Extract `<REPO>` (owner/name) from `git -C <WORKDIR> remote get-url origin`.
3. If `--repo` is passed, override `<REPO>` with the explicit value.
4. If `--path` is passed, override `<WORKDIR>` with the explicit value.
5. Validate that `<WORKDIR>` exists and is a git repository.

6. **Pull latest changes** from the upstream branch so the working directory is up to date before any work begins:
   ```bash
   git -C <WORKDIR> checkout <BASE_BRANCH>
   git -C <WORKDIR> pull --rebase origin <BASE_BRANCH>
   ```

### Phase 1a — Codex mode: Fetch & analyze PR review comments (conditional)

If `--resolve-codex` flag is set, this phase replaces the standard issue-fetching logic:

1. **Fetch PR details** for each provided PR number:
   ```bash
   gh pr view <PR_NUMBER> --repo <REPO> --json number,title,headRefName,baseRefName,body,author
   ```
   Collect the base branch as `<CODEX_BASE_REF>` for each PR — fix branches will target this.

2. **Fetch all review comments** from each PR using the GitHub API. Get the full thread data:
   ```bash
   gh api repos/<REPO>/pulls/<PR_NUMBER>/comments?per_page=100 --paginate
   ```
   Each comment includes: `id`, `body`, `path` (file), `line`, `start_line`, `side`, `commit_id`, `pull_request_review_id`, `thread_id`, `created_at`, `user`.

3. **Identify unresolved threads** by grouping comments by `thread_id`:
   - Use the GraphQL API to check if each thread is resolved:
     ```bash
     gh api graphql -f query='
       query($owner:String!,$repo:String!,$pr:Int!){
         repository(owner:$owner,name:$repo){
           pullRequest(number:$pr){
             reviewThreads(first:100){
               nodes{id isResolved isOutdated comments(first:10){nodes{body path line}}}
             }
           }
         }
       }' -f owner=<OWNER> -f repo=<REPO> -f pr=<PR_NUMBER>
     ```
   - Filter to only threads where `isResolved` is `false` and `isOutdated` is `false`.
   - If GraphQL is unavailable, use this fallback heuristic: a thread is "unresolved" if it has no reply comment from the PR author (the person who opened the PR) that indicates it was addressed (contains keywords like "fixed", "done", "resolved", "addressed").

4. **Convert each unresolved thread into a synthetic "issue"** with:
   - **Title**: `"Fix codex review: {file_path} — {short summary of comment}"`
   - **Body**: Full context including the file path, line numbers, the review comment text, a link to the original review comment, the original PR number
   - **Labels**: `codex-review`, `auto`
   - **Reasoning level**: Always `--r-mid` unless overridden by explicit flags
   - **Thread metadata**: Store `thread_id`, `file_path`, `line`, `pr_number`, `original_branch` for use during push phase

   The synthetic issues feed into the same pipeline as normal issues (Phase 2 onward).

5. **Report to user**: "Codex mode: found N unresolved thread(s) across M PR(s). Created N fix tasks."

   After creating synthetic issues, skip Phase 1b and proceed directly to Phase 2 (the synthetic issues feed into the same pipeline).

### Phase 1b — Normal mode: Fetch & analyze all issues (sequential)

If `--resolve-codex` is NOT set, use the standard issue-fetching logic:

1. **Fetch all issues** in a single parallel batch:
   ```bash
   gh issue view <ISSUE_NUMBER> --repo <REPO> --json number,title,body,labels,state,author,createdAt,comments
   ```

2. **Analyze complexity** per issue based on title, body, and labels. Use explicit reasoning flag if provided; otherwise auto-detect per issue:
   - **Simple**: typo, minor UI fix, documentation → **low** reasoning
   - **Medium**: bug fix, small feature, refactor → **mid** reasoning
   - **Complex**: architectural change, major feature, performance → **high** reasoning
   - **Critical**: security, breaking change, cross-cutting → **extra high** reasoning

3. **Apply model flag** if `--m-flash` or `--m-pro` was passed. Defaults to `--m-flash` if neither is provided:
   - Save the current model from `~/.claude/settings.json`.
   - `--m-flash`: Update to `mimo-v2.5`.
   - `--m-pro`: Update to `mimo-v2.5-pro`.
   - Restart the LiteLLM bridge:
     ```bash
     systemctl --user daemon-reload && systemctl --user restart litellm-kimi.service
     ```

### Phase 2 — Spawn sub-agents (parallel)

1. **Spawn one sub-agent per issue** in parallel (via `run_in_background: true`). Pick the best agent type per issue:
   - `voltagent-core-dev:frontend-developer` — UI changes, component work, styling, layout
   - `voltagent-core-dev:fullstack-developer` — features touching both frontend and API
   - `voltagent-core-dev:backend-developer` — API, database, server-side logic
   - `voltagent-lang:typescript-pro` — TypeScript-specific fixes, type errors, generics
   - `voltagent-qa-sec:debugger` — complex bug reproduction and diagnosis
   - `voltagent-core-dev:ui-designer` — visual design, theming, accessibility
   - `voltagent-core-dev:design-bridge` — translating design specs into UI

   Each sub-agent prompt must include:
   - Full issue details (title, body, labels)
   - The working directory: `<WORKDIR>`
   - Branch name: `fix/issue-<ISSUE_NUMBER>`
   - The reasoning level selected
   - Clear instructions to:
     a. Create and switch to the branch
     b. Implement the fix
     c. Run `npm run build` to verify
     d. If build fails, fix and retry until it passes
     e. **Do not include any AI branding** ("Claude Code", "Anthropic", "Co-Authored-By", "🤖", "Generated with", "Copilot", "AI-generated") in commit messages, comments, or code. An automated scan (Phase 2.5) will flag and strip any branding found — but it is faster and cleaner if you avoid it entirely
     f. Report back the final status (pass/fail), a **summary of changes** (list of files modified and what was done in each), and **verification details** (build output, any manual checks performed)

   **If in codex mode (`--resolve-codex`)**, also include:
   - The file path and line numbers from the review comment (so the agent knows exactly where the issue is)
   - The original review comment text verbatim
   - The original PR number and branch name (for context)
   - Branch name format: `fix/pr-<PR_NUMBER>-<thread-index>` (thread index is 0-based per PR)

### Phase 2.5 — AI branding scan & strip

Before any branch is pushed or any commit is finalized, **every branch must pass an automated branding check**. This runs per-branch after the sub-agent completes but before Phase 3.

**Scan patterns** (case-insensitive grep across all tracked and staged files in the branch diff):

```
claude
anthropic
co-authored-by
generated with
🤖
copilot
copilot-generated
ai-generated
ai-generated-by
created by claude
```

**How to run** (from `<WORKDIR>`, per branch):

```bash
git -C <WORKDIR> checkout <BRANCH_NAME>

# 1. Scan code files in the diff for branding in comments/content
git -C <WORKDIR> diff <BASE_BRANCH>...<BRANCH_NAME> --unified=0 \
  | grep -iE 'claude|anthropic|co-authored-by|generated with|copilot|copilot-generated|ai-generated|created by claude' \
  | grep '^[+-]' \
  | grep -vE '^\+\+\+|^---' \
  || true

# 2. Scan commit messages for branding
git -C <WORKDIR> log <BASE_BRANCH>..<BRANCH_NAME> --format='%B' \
  | grep -iE 'claude|anthropic|co-authored-by|generated with|copilot|copilot-generated|ai-generated|created by claude' \
  || true
```

**If branding is found:**

1. **In code files** — use `sed -i` to strip matching lines from every file in the branch diff that contains branding. Target the exact lines returned by the grep. Common cases:
   - Comment lines: `// Generated by Claude` or `/* Created by Claude Code */` → remove entire line
   - Footer blocks in commit-tracked files (e.g., `.gitmessage` templates) → remove the block
   - If stripping breaks the file (e.g., removes a required import or syntax), fix the surrounding code

2. **In commit messages** — rewrite the commit message on the most recent commit(s) to remove the branding lines. Use `git commit --amend` if it's the HEAD commit, or `git rebase -i` for earlier commits. Never leave a commit message with branding.

3. **Re-verify** — after stripping, re-run the grep to confirm zero matches. If branding persists (e.g., it's in a binary or generated file that shouldn't be committed), report to the user and ask for guidance.

**This check is mandatory.** No branch may proceed to push without a clean branding scan.

### Phase 3 — Conflict surface detection

After all sub-agents complete but before any git operations:

1. **Detect file overlaps between branches**:
   - For each successful branch, run:
     ```bash
     git diff --stat <BASE_BRANCH>...fix/issue-<N>
     ```
   - Build an overlap map showing which branches touch the same files
   - Report to the user: "Issues #42 and #43 both touch src/App.tsx — they'll be pushed sequentially with rebase"
   - Sort branches by issue number (ascending) — this defines the push order

### Phase 4 — Pull latest, push, and create PRs

**Before any git operations** — verify commit and PR hygiene:
- **No AI branding**: Phase 2.5 already scanned and stripped branding from code and commit messages. Verify the scan passed for every branch. If any branding slips through at this stage, stop and fix it before pushing.
- **No AI branding in PR bodies**: PR bodies must be written as normal developer work. Never include "Claude Code", "Anthropic", "Co-Authored-By: Claude", "🤖", "Generated with", or any AI/assistant branding. If the sub-agent included branding in its summary, rewrite the PR body.
- Commits should use the conventional subject line: `fix: <description>` or `feat: <description>`.
- If the sub-agent included AI-generated tags in commits, amend/squash them out before pushing.

Before any branch operations, **pull the latest upstream changes** to ensure everything is based on current code:

```bash
git -C <WORKDIR> checkout <BASE_BRANCH>
git -C <WORKDIR> pull --rebase origin <BASE_BRANCH>
```

1. **Process branches in order** (issue-number or thread-index ascending). Branch naming depends on mode:

   **Normal mode** — branch: `fix/issue-<ISSUE_NUMBER>`, base: `<BASE_BRANCH>` (default: `main`)

   **Codex mode** — branch: `fix/pr-<PR_NUMBER>-<thread-index>`, base: `<CODEX_BASE_REF>` (the original PR's base branch, e.g., `main`, `develop`, or a feature branch)

   For each successful branch:
   - `git checkout <BRANCH_NAME>`
   - Review recent commits on this branch. If any contain AI branding, squash or amend them.
   - `git pull --rebase origin <BASE>` — rebase onto latest base branch (which now includes any previously pushed fixes from this batch)
   - If **rebase conflicts** occur:
     - Spawn `voltagent-qa-sec:debugger` to resolve them automatically
     - If resolution fails → mark issue as **CONFLICT**, report the conflicting files to the user, and skip to the next issue
   - `git push origin <BRANCH_NAME>`

   - If `--pr` flag was passed:
     - **Build the PR body** from the sub-agent's implementation summary. Use this format:
       ```markdown
       ## Summary
       [2-4 sentence description of what was fixed and why]

       ## Changes
       - [specific change 1 — file name + what was done]
       - [specific change 2 — file name + what was done]
       - [specific change 3 — file name + what was done]

       ## Verification
       - [how the fix was tested / build result]
       ```
     - If the sub-agent did not provide a detailed summary, generate it by reading the diff:
       ```bash
       git diff <BASE>...<BRANCH_NAME> --stat
       git log <BASE>..<BRANCH_NAME> --oneline
       ```
     - Create the PR:
       ```bash
       gh pr create --repo <REPO> \
         --title "Fix #<ISSUE_NUMBER>: <ISSUE_TITLE>" \
         --body "<PR_BODY>" \
         --head <BRANCH_NAME> \
         --base <BASE>
       ```
     - Report the PR URL.
   - If no `--pr` flag:
     - Report the branch name.

   - **Post a detailed comment** on the relevant item with the summary, changes, and verification:
     - **Normal mode**: Comment on the GitHub issue (unless `--no-comment`):
       ```bash
       gh issue comment <ISSUE_NUMBER> --repo <REPO> --body "<RESOLUTION_COMMENT>"
       ```
     - **Codex mode**: Comment on the original PR linking to the fix branch or fix PR:
       ```bash
       gh pr comment <PR_NUMBER> --repo <REPO> --body "**Fix branch created for unresolved review thread:** \n\n<RESOLUTION_COMMENT>\n\nBranch: \`<BRANCH_NAME>\`"
       ```

3. **Restore original model** in `~/.claude/settings.json` and restart the bridge if it was changed.

4. **Report final summary**:
   - List successfully pushed branches/PRs
   - List any CONFLICT items (those that were skipped) with the files that conflicted

## Important Notes

- **AI branding is a hard gate.** Phase 2.5 must run on every branch and return clean before the branch can be pushed. If branding is found in code or commit messages, it is stripped automatically. If stripping is not possible (binary files, generated files), report to the user.
- Always confirm with the user before pushing or creating PRs.
- For bugs, try to reproduce first (spawn `voltagent-qa-sec:debugger` if needed).
- Report back: complexity decisions, model used, which sub-agents were spawned, and final status per issue.
- If a sub-agent fails, inform the user and continue with remaining issues.

---

When invoked, the skill accepts an alias or --repo/--path, followed by one or more issue numbers and optional flags:

```
/gh-issue-resolver pms 42 --pr --r-high --m-flash
/gh-issue-resolver pms 42 43 44 --pr --r-mid --m-flash
/gh-issue-resolver --repo tarasinghrajput/empowered-indian --path "/mnt/c/Users/72619/OneDrive/Documents/React Apps/empowered-indian" 1 --pr

# Codex mode examples:
/gh-issue-resolver pms 123 --resolve-codex --pr --r-mid
/gh-issue-resolver pms 123 124 --resolve-codex --pr
/gh-issue-resolver pms 456 --resolve-codex```

