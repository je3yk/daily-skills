---
name: daily-list
description: Lists today's daily plan with current task progress. Compact by default, showing status and title. Use --verbose for full details including priority, estimate, labels, and notes. Usage: /daily-list [--verbose]
---

List today's daily plan with current progress.

## Input

- Optional: `--verbose` flag — show full task details instead of compact view

## Step 1 — Load the daily plan

Read `~/Documents/daily/YYYY-MM-DD.json` (today's date).

If the file does not exist, inform the user that no plan exists for today and suggest running `/daily-create`.

## Step 2 — Render the plan

### Compact (default)

Use status icons:
- `[x]` — Completed
- `[~]` — In progress
- `[p]` — Paused
- `[ ]` — Not started
- `[-]` — Skipped

Group tasks by priority in order: Blocker → Critical → Important → Optional.

```
# Daily Plan — March 21, 2026

## Blockers
[x] ENG-123 — Fix login bug (2h)

## Critical
[~] ENG-456 — Add payment method (3h)

## Important
[ ] TASK-1  — Research React Query v5 migration (2h)

## Optional
[-] ENG-789 — Update README (30m)

---
Progress: 1 completed · 1 in progress · 1 not started · 1 skipped
Total estimated: 7h 30m
```

### Verbose (`--verbose`)

Same grouping and icons, but expand each task:

```
## Critical
[~] ENG-456 — Add payment method
    Priority: Critical | Estimate: 3h | Labels: payments, backend
    Notes: Focus on Stripe webhook handling first
    Context: context/ENG-456.md
```

Show `Context: context/{id}.md` only if a context file exists for the task. Omit the line if `contextFile` is null.

## Step 3 — Output

Print the rendered plan to the terminal. Do not save any files.
