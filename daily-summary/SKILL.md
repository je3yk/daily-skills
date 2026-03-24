---
name: daily-summary
description: Generates an end-of-day summary in Markdown with a factual recap and a reflection section. Prints to terminal and saves to ~/Documents/daily/YYYY-MM-DD-summary.md. Ready to copy to Slack, Notion, or any other tool.
---

Generate a summary for today's work session.

## Step 1 — Load the daily plan

Read `~/Documents/daily/YYYY-MM-DD.json` (today's date).

If the file does not exist, inform the user that no plan was found for today and stop.

## Step 2 — Ask for reflection input

Ask the user:
> "Anything you'd like to add to today's summary? (blockers, observations, notes for tomorrow — press enter to skip)"

Store the response for use in the Reflection section.

## Step 3 — Generate the summary

Build a Markdown document with two sections:

### Section 1: Recap

List all tasks grouped by final status. For each task include the ID, title, and any skip reason or notes.

### Section 2: Reflection

- **Blockers**: tasks that were skipped or paused due to external dependencies — flag them and suggest follow-up actions
- **Carry-overs**: tasks still In progress or Not started — list them with a note that they will appear in tomorrow's plan
- **User notes**: include anything the user added in Step 2
- **Agent observation** (optional): if there are patterns worth noting (e.g. all blockers are in the same area, estimates were consistently off), mention them briefly

## Step 4 — Output

Print the full Markdown summary to the terminal.

Save the same content to `~/Documents/daily/YYYY-MM-DD-summary.md`.

Confirm:
```
Summary saved to ~/Documents/daily/2026-03-21-summary.md
```

---

## Output format

```markdown
# Daily Summary — March 21, 2026

## Recap

### Completed
- **ENG-123** — Fix login bug
- **ENG-456** — Add payment method

### In progress
- **TASK-1** — Research React Query v5 migration
  _Context saved. Will carry over to tomorrow._

### Skipped
- **ENG-789** — Update README
  _Skip reason: Not a priority this sprint._

### Not started
- **ENG-999** — Refactor settings page
  _Will carry over to tomorrow._

---

## Reflection

**Blockers / carry-overs:**
- TASK-1 and ENG-999 will be added to tomorrow's plan automatically.

**Notes:**
[User-provided notes here, if any]

**Observations:**
Two tasks were completed ahead of estimate. ENG-789 was skipped — worth revisiting priority with the team.
```
