---
name: daily-task-complete
description: "Marks a task as completed in the daily plan. Usage: /daily-task-complete {task-id}"
---

Mark a task as completed in today's daily plan.

## Input

The argument is a task ID — either a Linear issue ID (e.g. `ENG-123`) or a manual task ID (e.g. `TASK-1`).

## Step 1 — Load the daily plan

Read `~/Documents/daily/YYYY-MM-DD.json` (today's date). Find the task matching the provided ID.

If the file does not exist or the task is not found, inform the user and stop.

## Step 2 — Update task status

Set the task's `status` to `Completed` in the JSON file and save it.

## Step 2.5 — Post summary comment to Linear (if applicable)

Only run this step if the task has `source: "linear"` (i.e. it is a Linear issue).

### Generate the summary

- If the task has a `contextFile`, read it and use it as the primary input.
- Otherwise, synthesize from the current conversation context — recent tool calls, files read/edited, decisions made, and outcomes.
- If there is no context file and no useful conversation context to summarize, skip auto-generation and ask the user:

  > "No context found for this task. Would you like to add a comment to the Linear issue? Type a summary below, or press enter to skip."

  If the user skips (presses enter without input), do not post a comment and proceed to Step 3.

### Format the comment

Produce a concise markdown comment suitable for a team member reading the Linear issue:

```markdown
## Completed: {task title}

**What was done:**
- [key action or change]
- [key action or change]
- ...

**Outcome:**
[One sentence describing the result]
```

Keep it factual and brief. Do not copy the full context file verbatim.

### Confirm before posting

Show the user a preview of the comment:

```
Ready to post this comment to {task-id} on Linear:

---
{comment content}
---

Post it? (y/n)
```

If the user confirms (y), post the comment using the Linear MCP `save_comment` tool on the issue matching the task ID.

If the user declines (n), skip posting and proceed to Step 3.

If posting fails (API error, network issue, etc.), print a warning and continue:

```
Warning: could not post comment to Linear. Task marked as completed.
```

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
