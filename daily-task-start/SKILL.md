---
name: daily-task-start
description: "Starts a task from the daily plan. Loads all context (Linear details, user notes, technical interpretation, previous context file), explores the codebase for relevant files, proposes an implementation plan, and waits for user approval before acting. Usage: /daily-task-start {task-id}"
---

Start working on a task from today's daily plan.

## Step 0 — Clear context

**Agent instruction:** Discard all prior conversation context. Do not carry over any assumptions, findings, or decisions from earlier in this session. Everything you know about this task must come exclusively from what this skill loads in the steps below.

Print to the user:

```
Tip: for a clean start, run this in a fresh session (/clear or open a new window).
```

## Input

The argument is a task ID — either a Linear issue ID (e.g. `ENG-123`) or a manual task ID (e.g. `TASK-1`).

## Step 1 — Load the daily plan

Read `~/Documents/daily/YYYY-MM-DD.json` (today's date). Find the task matching the provided ID.

If the file does not exist or the task is not found, inform the user and stop.

## Step 2 — Update task status

Set the task's `status` to `In progress` in the JSON file and save it.

## Step 3 — Load all context

Gather everything known about this task:

1. **From the plan file**: title, description, technicalInterpretation, notes, estimate, priority, labels
2. **From Linear** (if `source` is `linear`): re-fetch the latest issue details using Linear MCP in case anything changed since `daily-create` was run. Get any comments, linked issues, or attachments that may be relevant.
3. **From context file** (if `contextFile` is set in the plan): read `~/Documents/daily/context/{task-id}.md` — this contains progress notes from a previous work session.

## Step 4 — Explore the codebase

Based on the task description, technical interpretation, and labels, explore the current working directory to find relevant files. Look for:
- Files mentioned explicitly in the description or comments
- Files related to the feature area (e.g. auth middleware for a login bug)
- Recent git changes to related files (run `git log --oneline -10 -- <relevant paths>` if helpful)
- Existing tests for the affected area

List the files found but do not read all of them — summarize what each likely contains and why it is relevant.

## Step 5 — Present full context and proposed plan

Print a structured brief for the user:

```
## Starting: ENG-123 — Fix login bug

**Priority:** Blocker | **Estimate:** 2h | **Labels:** auth, frontend

**Description:**
Users are getting logged out randomly after 30 minutes.

**Technical interpretation:**
Likely a JWT expiry / refresh token issue in the auth middleware. The refresh token flow may not be correctly extending the session.

**Your notes:**
Focus on the refresh token flow first.

**Previous context:**
[If a context file exists, summarize the previous progress here]

**Relevant files:**
- src/auth/middleware.ts — JWT validation and refresh logic
- src/auth/session.ts — Session persistence layer
- src/api/auth.ts — Auth API endpoints
- tests/auth.test.ts — Existing auth tests

**Proposed plan:**
1. Read middleware.ts to trace the token refresh flow
2. Identify where session expiry is calculated
3. Check if refresh tokens are being issued and stored correctly
4. Write a failing test that reproduces the logout issue
5. Fix the logic and verify the test passes

Ready to start? Any adjustments to the plan?
```

## Step 6 — Wait for approval

Do not read files, edit code, or take any action until the user confirms. If the user suggests changes to the plan, update it and confirm again before proceeding.

Once approved, begin executing the plan step by step, checking in with the user at natural decision points.

## Next actions

After the plan is confirmed and work begins, print:

```text
What's next?
  /daily-task-update {id}    — save progress and pause the task
  /daily-task-complete {id}  — mark the task as done
  /daily-task-skip {id}      — skip with a reason
```
