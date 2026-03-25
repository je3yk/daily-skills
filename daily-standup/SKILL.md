---
name: daily-standup
description: "Prepares a short standup note from yesterday's summary (or plan) and today's plan. Sections: yesterday, today, blockers. Print only. Usage: /daily-standup"
---

Prepare a standup note for today.

## Step 1 — Load yesterday's data

Determine "yesterday" as the most recent past day with available data. Search backwards from the day before today:

1. Look for `~/Documents/daily/YYYY-MM-DD-summary.md` — if found, use it as the source for yesterday's recap.
2. If no summary file exists for any past day, fall back to the most recent `~/Documents/daily/YYYY-MM-DD.json` plan file.

If no past data is found at all, note that and continue to Step 2.

### Extracting yesterday's recap from a summary file

Read the **Recap** section. Extract tasks grouped by status:
- **Completed** — list title only
- **In progress** — list title with note "still in progress"
- **Skipped** — list title with skip reason if present
- **Not started** — list title with note "not started, carries over"

### Extracting yesterday's recap from a plan JSON

Read the `tasks` array. Group by `status` field using the same categories above. Use `notes` field for skip reasons.

## Step 2 — Load today's plan

Read `~/Documents/daily/YYYY-MM-DD.json` (today's date).

If the file does not exist:
> "No plan found for today. Run `/daily-create` to set one up before your standup, or press enter to continue with just yesterday's recap."

Wait for input. If the user presses enter (skips), proceed without a today section.

## Step 3 — Identify blockers

From yesterday's data, extract any tasks that:
- Have status `Paused`
- Have status `Skipped` with a skip reason mentioning a dependency, blocker, or external party (look for keywords: blocked, waiting, depends, external, team, PR, review)

From today's plan (if available), flag any tasks carrying over from yesterday with `Paused` or `In progress` status where a context file exists — these may have open questions.

## Step 4 — Render the standup note

Print the standup note in the following format:

```
## Standup — {Day, Month DD}

### Yesterday
- Completed: {title}
- Completed: {title}
- In progress: {title} (still in progress)
- Skipped: {title} — {skip reason}
- Not started: {title} (carries over)

### Today
- {title} [{priority}]
- {title} [{priority}]
- {title} [{priority}]

### Blockers
- {title} — {reason or "paused, needs follow-up"}
```

Rules:
- **Yesterday**: list tasks in completed → in progress → skipped → not started order. Omit empty groups entirely.
- **Today**: list only `Not started` and `In progress` tasks from today's plan, sorted by priority (Blocker → Critical → Important → Optional). Include priority label in brackets. Omit `Completed` and `Skipped` tasks.
- **Blockers**: omit the section entirely if there are no blockers.
- Keep each line to one line — no multi-line descriptions.

## Step 5 — Output

Print the standup note to the terminal. Do not save any files.
