---
name: daily-task-skip
description: Skips a task from the daily plan. Asks for a reason and stores it as a note on the task. Skipped tasks are not carried over to the next day. Usage: /daily-task-skip {task-id}
---

Skip a task from today's daily plan.

## Input

The argument is a task ID — either a Linear issue ID (e.g. `ENG-123`) or a manual task ID (e.g. `TASK-1`).

## Step 1 — Load the daily plan

Read `~/Documents/daily/YYYY-MM-DD.json` (today's date). Find the task matching the provided ID.

If the file does not exist or the task is not found, inform the user and stop.

## Step 2 — Ask for a reason

Ask the user:
> "Why are you skipping ENG-123 — Fix login bug? (press enter to skip)"

This is optional — if the user presses enter without providing a reason, store an empty note.

## Step 3 — Update the daily plan

In `~/Documents/daily/YYYY-MM-DD.json`:
- Set `status` to `Skipped`
- Set `notes` to the reason provided (appended to any existing notes, prefixed with "Skip reason: ")

Save the file.

## Step 4 — Confirm

Print a brief confirmation followed by next actions:

```
Task ENG-123 — Fix login bug skipped.
Note: Blocked by ENG-500, will pick up next sprint.

Remaining tasks:
  [Not started] ENG-456 — Add payment method
  [Not started] TASK-1  — Research React Query v5 migration

What's next?
  /daily-task-start {next-task-id}  — start the next task ({next-task-title})
  /daily-list                        — view full plan and progress
```

Use the ID and title of the first `Not started` task in priority order for `{next-task-id}` and `{next-task-title}`. If no not-started tasks remain, omit the `daily-task-start` line.
