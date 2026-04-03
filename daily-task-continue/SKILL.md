---
name: daily-task-continue
description: "Resumes a paused task by loading its saved context file and the latest task details, then presents a full briefing before starting work. Usage: /daily-task-continue {task-id}"
---

Resume work on a paused task.

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

If the file does not exist, look for the most recent daily plan file in `~/Documents/daily/` that contains this task ID — the task may have been started on a previous day.

If the task is not found in any plan file, inform the user and stop.

## Step 2 — Load the context file

Read `~/Documents/daily/context/{task-id}.md`. This file contains the progress snapshot from the previous work session.

If the file does not exist, inform the user that no saved context was found and ask if they want to proceed without it (treating it like a fresh `daily-task-start`).

## Step 3 — Update task status

Set the task's `status` to `In progress` in the JSON file and save it.

## Step 4 — Present the full briefing

Print a structured summary to orient the user before resuming:

```
## Resuming: ENG-123 — Fix login bug

**Priority:** Blocker | **Estimate:** 2h | **Labels:** auth, frontend

**Your notes:**
Focus on the refresh token flow first.

---

### Previous session context
**Last updated:** 2026-03-20 16:45

**What was done:**
[From context file]

**Current state:**
[From context file]

**Open questions:**
[From context file]

**Next steps:**
[From context file]

**Relevant files:**
[From context file]

---

Ready to continue? Any changes to the plan before we start?
```

## Step 5 — Wait for confirmation

Do not read files, edit code, or take any action until the user confirms. Once confirmed, resume from the "Next steps" in the context file.

## Next actions

After the briefing is confirmed and work resumes, print:

```text
What's next?
  /daily-task-update {id}    — save progress and pause the task
  /daily-task-complete {id}  — mark the task as done
  /daily-task-skip {id}      — skip with a reason
```
