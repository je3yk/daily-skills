# daily-skills set

A set of skills for structured daily planning and task management.

These skills integrate with [Linear](https://linear.app) (via MCP) to fetch issue details, track task progress across sessions, and generate end-of-day summaries.

## Installation

Copy the skill directories into your agent skills folder:

```bash
cp -r daily-*/ ~/.claude/skills/
```

Or clone directly into your skills folder:

```bash
git clone https://github.com/je3yk/daily-skills ~/.claude/skills/daily-skills
# then move the skill directories one level up
mv ~/.claude/skills/daily-skills/daily-*/ ~/.claude/skills/
```

You can also use this command

```bash
npx skills@latest add je3yk/daily-skills/daily-create
```

## Skills

### `/daily-create [task-ids or descriptions]`

Creates a structured plan for the day.

- Accepts Linear issue IDs (e.g. `ENG-123`) and/or free-form task descriptions
- Fetches Linear task details (title, description, priority, estimate, labels) via MCP
- Proposes a technical interpretation for each task and asks for your notes
- Classifies tasks as Blocker / Critical / Important / Optional
- Merges incomplete tasks carried over from the previous day
- Saves the plan to `~/Documents/daily/YYYY-MM-DD.json`

```
/daily-create ENG-123 ENG-456 "Research React Query v5 migration"
```

### `/daily-list [--verbose]`

Displays today's plan with current task statuses. Add `--verbose` for full details (priority, estimate, labels, notes).

### `/daily-task-start {task-id}`

Starts a task. Loads all context (Linear details, notes, technical interpretation, previous context file), explores the codebase for relevant files, proposes an implementation plan, and waits for approval before acting.

### `/daily-task-update {task-id}`

Pauses an in-progress task and saves a progress snapshot — current work, open questions, next steps — to a context file so another agent session can resume it seamlessly.

### `/daily-task-continue {task-id}`

Resumes a paused task by loading its saved context file and the latest task details, then presents a full briefing before starting work.

### `/daily-task-complete {task-id}`

Marks a task as completed in today's plan.

### `/daily-task-skip {task-id}`

Skips a task. Asks for a reason, stores it as a note, and excludes the task from carry-over to the next day.

### `/daily-delete {YYYY-MM-DD} [--dry-run]`

Deletes a daily plan and all associated files (plan JSON, summary Markdown, context files). Runs a safety check to avoid deleting context files still referenced by other plans. Supports `--dry-run` to preview what would be deleted.

### `/daily-add-task [task-ids or descriptions]`

Adds new tasks to today's plan and re-sorts it.

- Accepts Linear issue IDs and/or free-form task descriptions as arguments
- Falls back to interactive mode if no arguments provided
- Re-sorts all active (not completed/skipped) tasks by priority after adding
- Shows the updated plan for review before saving

```
/daily-add-task ENG-999 "Quick sync with design team"
```

### `/daily-standup`

Prepares a short standup note from yesterday's data and today's plan.

- Reads yesterday's summary (`.md`) if available; falls back to the plan JSON of the most recent past day
- If today's plan doesn't exist yet, prompts to create it or allows skipping
- Outputs three sections: **Yesterday**, **Today**, **Blockers**
- Print only — nothing is saved

### `/daily-summary`

Generates an end-of-day summary in Markdown — a factual recap of completed/skipped/in-progress tasks plus a reflection section. Prints to terminal and saves to `~/Documents/daily/YYYY-MM-DD-summary.md`. Ready to paste into Slack, Notion, or any other tool.

## File structure

Plans and context files are stored in `~/Documents/daily/`:

```
~/Documents/daily/
  2026-03-24.json          # today's plan
  2026-03-24-summary.md    # end-of-day summary
  context/
    ENG-123.md             # saved context for a paused task
```

Files older than 7 days are cleaned up automatically by `/daily-create`.

## Requirements

- [Claude Code](https://claude.ai/code)
- Linear MCP plugin (optional — skills degrade gracefully if not available)

## Roadmap

- [ ] Allow users to add new issues during the day and rearrange their priority and order.

- [ ] Support other agents. It may already work with other agents, but I haven’t tested it yet.

- [ ] Support integrations with other issue tracking and project management tools.
