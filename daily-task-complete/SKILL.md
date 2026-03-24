---
name: daily-task-complete
description: Marks a task as completed in the daily plan. Usage: /daily-task-complete {task-id}
---

Mark a task as completed in today's daily plan.

## Input

The argument is a task ID — either a Linear issue ID (e.g. `ENG-123`) or a manual task ID (e.g. `TASK-1`).

## Step 1 — Load the daily plan

Read `~/Documents/daily/YYYY-MM-DD.json` (today's date). Find the task matching the provided ID.

If the file does not exist or the task is not found, inform the user and stop.

## Step 2 — Update task status

Set the task's `status` to `Completed` in the JSON file and save it.

## Step 3 — Confirm

Print a brief confirmation and show remaining tasks:

```
Task ENG-123 — Fix login bug marked as completed.

Remaining tasks:
  [In progress] ENG-456 — Add payment method
  [Not started] TASK-1  — Research React Query v5 migration
  [Not started] ENG-789 — Update README
```

If there are remaining not-started tasks, print:

```text
What's next?
  /daily-task-start {next-task-id}  — start the next task ({next-task-title})
```

Use the ID and title of the first `Not started` task in priority order.

If all tasks are completed or skipped, congratulate the user and print:

```text
What's next?
  /daily-summary  — generate today's end-of-day summary
```
