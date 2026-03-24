---
name: daily-create
description: Creates a structured daily plan. Accepts Linear issue IDs and/or free-form task descriptions as arguments. Fetches Linear task details, proposes technical interpretations, merges incomplete tasks from the previous day, classifies by priority, and saves the plan to ~/Documents/daily/YYYY-MM-DD.json.
---

Create a plan for today's work session.

## Input

The user may pass task identifiers and/or free-form tasks directly in the command arguments, for example:
```
/daily-create ENG-123 ENG-456 "Research React Query v5 migration"
```

Parse the arguments:
- Strings matching Linear issue ID patterns (e.g. `ENG-123`, `PROJ-42`) → fetch from Linear
- Quoted strings or plain text → manual tasks

## Step 1 — Cleanup old files

Silently delete files in `~/Documents/daily/` that are older than 7 days. Do not mention this to the user.

For each candidate file:

- `YYYY-MM-DD.json` and `YYYY-MM-DD-summary.md` — delete if older than 7 days
- `context/{task-id}.md` — before deleting, scan **all remaining** (non-expired) plan files in `~/Documents/daily/`. If any task in any of those plans has a `contextFile` pointing to this file, **skip deletion silently**. Only delete context files that are not referenced by any surviving plan.

## Step 2 — Fetch Linear tasks

For each Linear issue ID provided, use the Linear MCP to fetch:
- Title
- Description
- Priority (Urgent / High / Medium / Low / No Priority)
- Estimate
- Labels
- Current status

If Linear MCP is not available, inform the user and treat the IDs as manual tasks with only the ID as title.

## Step 3 — Load previous day's incomplete tasks

Find the most recent `~/Documents/daily/YYYY-MM-DD.json` file (ignoring today's date). If found:
- Extract all tasks with status `Not started`, `In progress`, or `Paused`
- Carry them over with all their existing fields (title, description, technicalInterpretation, notes, contextFile, etc.)
- Re-classify their priority in Step 5 (do not preserve old classification)

## Step 4 — Ask for more tasks

After processing the initial input, ask once:
> "Any other tasks to add? You can paste Linear issue IDs or describe tasks freely. Press enter to skip."

Accept any additional input and process it the same way. Do not ask again after this.

## Step 5 — Technical interpretation

For each task (Linear and manual alike):
1. Read the title, description, and any user notes
2. Propose a concise technical interpretation: what area of the codebase is likely involved, what the approach could be, and any potential risks or dependencies
3. Present it to the user for review

Format per task:
```
Task: ENG-123 — Fix login bug
Description: Users are getting logged out randomly after 30 minutes
Technical interpretation: Likely a JWT expiry / refresh token issue in the auth middleware. Will need to trace token refresh logic and session persistence.

Any notes or corrections? (press enter to skip)
```

Store the user's response as `notes` on the task. If they skip, leave `notes` empty.

## Step 6 — Classify priority

Map Linear priorities to internal categories:
- Urgent → Blocker
- High → Critical
- Medium → Important
- Low / No Priority → Optional

For manual tasks without explicit priority, infer from the description (e.g. if it mentions "blocking", "release", "urgent" → Blocker; research tasks → Optional by default).

Also flag any tasks where the description suggests a higher or lower priority than the Linear priority indicates (e.g. a "Low" priority ticket that mentions it is blocking a release). Present these flags to the user.

After processing all tasks, show the full classification list for review:
```
Priority classification — please review:

  [Blocker]   ENG-123 — Fix login bug
  [Critical]  ENG-456 — Add payment method
  [Important] TASK-1  — Research React Query v5 migration
  [Optional]  ENG-789 — Update README

Any changes? (e.g. "change ENG-456 to Blocker") or press enter to confirm.
```

Accept corrections, update accordingly, then proceed.

## Step 7 — Sort tasks

Sort all tasks by:
1. Primary: priority order — Blocker → Critical → Important → Optional
2. Secondary: estimate ascending (shortest first). Tasks with no estimate go last within their priority group.

## Step 8 — Build and save the plan

Save the plan to `~/Documents/daily/YYYY-MM-DD.json` (using today's date).

JSON structure:
```json
{
  "date": "YYYY-MM-DD",
  "tasks": [
    {
      "id": "ENG-123",
      "title": "Fix login bug",
      "source": "linear",
      "status": "Not started",
      "priority": "Blocker",
      "estimate": "2h",
      "description": "Users are getting logged out randomly...",
      "labels": ["auth", "frontend"],
      "technicalInterpretation": "Likely a JWT expiry / refresh token issue...",
      "notes": "",
      "contextFile": null
    },
    {
      "id": "TASK-1",
      "title": "Research React Query v5 migration",
      "source": "manual",
      "status": "Not started",
      "priority": "Important",
      "estimate": "2h",
      "description": "",
      "labels": [],
      "technicalInterpretation": "Review the React Query v5 migration guide...",
      "notes": "",
      "contextFile": null
    }
  ]
}
```

For `id` on manual tasks: find the highest existing `TASK-{n}` index across today's plan and all carried-over tasks, then increment from there.

For carried-over tasks: preserve all existing fields. Update `status` back to `Not started` only if it was `Not started` previously. Keep `In progress` and `Paused` as-is.

## Step 9 — Display the plan

Print a clean Markdown summary of today's plan:

```
# Daily Plan — March 21, 2026

## Blockers
- [ ] ENG-123 — Fix login bug (2h) [carried over]
      auth, frontend

## Critical
- [ ] ENG-456 — Add payment method (3h)

## Important
- [ ] TASK-1 — Research React Query v5 migration (2h)

## Optional
- [ ] ENG-789 — Update README (30m)

---
Total estimated: 7h 30m
```

Mark carried-over tasks with `[carried over]`.

## Next actions

After displaying the plan, print:

```text
What's next?
  /daily-task-start {first-task-id}   — start working on the top priority task
  /daily-list                          — view the plan and progress at any time
```

Use the ID of the first task in the sorted plan for `{first-task-id}`.
