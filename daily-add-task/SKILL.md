---
name: daily-add-task
description: "Adds new tasks to today's plan and re-sorts it. Accepts Linear issue IDs and/or free-form task descriptions as arguments. Falls back to interactive if no args provided. Usage: /daily-add-task [task-ids or descriptions]"
---

Add one or more new tasks to today's daily plan.

## Input

The user may pass task identifiers and/or free-form descriptions directly in the command arguments:
```
/daily-add-task ENG-999 "Quick sync with design team"
```

Parse the arguments:
- Strings matching Linear issue ID patterns (e.g. `ENG-123`, `PROJ-42`) → fetch from Linear
- Quoted strings or plain text → manual tasks

If no arguments are provided, ask:
> "What task(s) would you like to add? You can paste Linear issue IDs or describe tasks freely."

Accept input and process it the same way.

## Step 1 — Load the daily plan

Read `~/Documents/daily/YYYY-MM-DD.json` (today's date).

If the file does not exist, inform the user that no plan exists for today and suggest running `/daily-create` instead. Stop.

## Step 2 — Fetch Linear tasks

For each Linear issue ID provided, use the Linear MCP to fetch:
- Title
- Description
- Priority (Urgent / High / Medium / Low / No Priority)
- Estimate
- Labels
- Current status

If Linear MCP is not available, inform the user and treat the IDs as manual tasks with only the ID as title.

## Step 3 — Technical interpretation

For each new task:
1. Read the title and description
2. Propose a concise technical interpretation: what area is likely involved, what the approach could be, any risks or dependencies
3. Present it to the user for review

Format per task:
```
Task: ENG-999 — Refactor settings page
Description: Clean up the settings page components
Technical interpretation: Likely involves splitting the monolithic SettingsPage component into smaller sub-components. Low risk, no external dependencies.

Any notes or corrections? (press enter to skip)
```

Store the user's response as `notes`. If they skip, leave `notes` empty.

## Step 4 — Classify priority

Map Linear priorities to internal categories:
- Urgent → Blocker
- High → Critical
- Medium → Important
- Low / No Priority → Optional

For manual tasks without explicit priority, infer from the description (e.g. "blocking", "urgent" → Blocker; research/sync tasks → Optional by default).

Flag any tasks where the description suggests a different priority than the Linear priority indicates. Present these flags to the user.

Show the classification for the new tasks only:
```
Priority classification — please review:

  [Important] ENG-999  — Refactor settings page
  [Optional]  TASK-2   — Quick sync with design team

Any changes? (e.g. "change ENG-999 to Critical") or press enter to confirm.
```

## Step 5 — Assign IDs to manual tasks

For each manual task (source: `manual`): find the highest existing `TASK-{n}` index across all tasks in today's plan, then increment from there.

## Step 6 — Re-sort the plan

Append the new tasks to the plan, then re-sort **all tasks except `Completed` and `Skipped`** by:
1. Primary: priority order — Blocker → Critical → Important → Optional
2. Secondary: estimate ascending (shortest first). Tasks with no estimate go last within their priority group.

`Completed` and `Skipped` tasks retain their positions at the end of the list and are not re-sorted.

## Step 7 — Show updated plan and confirm

Display the full updated plan (same format as `/daily-list`), with new tasks marked `[new]`:

```
# Daily Plan — March 25, 2026

## Blockers
[ ] ENG-123 — Fix login bug (2h)

## Critical
[ ] ENG-999 — Refactor settings page (3h) [new]

## Important
[~] ENG-456 — Add payment method (3h)

## Optional
[ ] TASK-2  — Quick sync with design team [new]
[-] ENG-789 — Update README (30m)

---
Progress: 0 completed · 1 in progress · 3 not started · 1 skipped
Total estimated: 8h
```

Then ask:
> "Confirm this plan? Any adjustments? (press enter to save)"

Accept free-form corrections (e.g. "move ENG-999 to Blocker"). Apply changes, re-sort if needed, then save.

## Step 8 — Save the plan

Write the updated tasks array back to `~/Documents/daily/YYYY-MM-DD.json`. Preserve all existing fields on every task.

Confirm:
```
Plan updated. 2 task(s) added.

What's next?
  /daily-task-start {top-task-id}  — start the top priority task
  /daily-list                       — view full plan and progress
```

Use the ID of the highest-priority `Not started` task for `{top-task-id}`.
