---
name: daily-task-update
description: Saves a progress snapshot for an in-progress task and pauses it. Summarizes current work, open questions, and next steps into a context file so work can be resumed later. Usage: /daily-task-update {task-id}
---

Save progress on a task and pause it.

## Input

The argument is a task ID — either a Linear issue ID (e.g. `ENG-123`) or a manual task ID (e.g. `TASK-1`).

## Step 1 — Load the daily plan

Read `~/Documents/daily/YYYY-MM-DD.json` (today's date). Find the task matching the provided ID.

If the file does not exist or the task is not found, inform the user and stop.

## Step 2 — Ask for progress summary

Ask the user:
> "What's the current state of this task? Describe what was done, what's still open, and any important context for picking this up later. (You can also just press enter and I'll summarize from the conversation.)"

If the user provides input, use it as the basis for the context document. If they press enter, summarize the current conversation context — recent tool calls, files read/edited, decisions made, and next steps identified.

## Step 3 — Write the context file

Create or overwrite `~/Documents/daily/context/{task-id}.md` with the following structure:

```markdown
# Context: ENG-123 — Fix login bug
**Last updated:** YYYY-MM-DD HH:MM
**Status at pause:** In progress

## What was done
[Summary of completed steps]

## Current state
[Where things stand right now — what's working, what isn't]

## Open questions
[Any unresolved questions or decisions that need to be made]

## Next steps
[Concrete next actions to take when resuming]

## Relevant files
[List of files that were read or modified, with brief notes on each]

## Notes
[Any other important context, gotchas, or decisions made]
```

Be specific and concrete — this document will be the only context available when resuming in a new session.

## Step 4 — Update the daily plan

In `~/Documents/daily/YYYY-MM-DD.json`:
- Set `status` to `Paused`
- Set `contextFile` to `context/{task-id}.md`

Save the file.

## Step 5 — Confirm

Print a brief confirmation followed by next actions:

```
Task ENG-123 paused. Context saved to ~/Documents/daily/context/ENG-123.md

What's next?
  /daily-task-continue {id}  — resume this task in a new session
  /daily-task-complete {id}  — mark the task as done without resuming
```
