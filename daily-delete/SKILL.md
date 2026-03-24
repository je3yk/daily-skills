---
name: daily-delete
description: Deletes a daily plan and all associated files (plan JSON, summary MD, context files) for a given date. Runs a safety check to avoid deleting context files still referenced by other plans. Always confirms before deleting. Supports --dry-run. Usage: /daily-delete {YYYY-MM-DD} [--dry-run]
---

Delete a daily plan and all its associated files.

## Input

- Required: a date in `YYYY-MM-DD` format (e.g. `2026-03-15`)
- Optional: `--dry-run` flag — show what would be deleted without actually deleting anything

## Step 1 — Locate files for the target date

Identify all files associated with the given date:

1. `~/Documents/daily/YYYY-MM-DD.json` — the plan file
2. `~/Documents/daily/YYYY-MM-DD-summary.md` — the summary file (may not exist)
3. Context files — read the plan JSON and collect all `contextFile` values that are non-null across all tasks

If the plan file does not exist, inform the user and stop.

## Step 2 — Safety check for context files

For each context file identified in Step 1, scan **all other** existing plan files in `~/Documents/daily/` (i.e. every `*.json` file except the one being deleted). Check if any task in those files has a `contextFile` value pointing to the same file.

Categorize context files as:
- **Safe to delete** — not referenced by any other plan
- **Protected** — still referenced by at least one other plan (note which plan files reference it)

## Step 3 — Build the deletion plan

Compile the full list of what will happen:

```
Files to delete:
  ~/Documents/daily/2026-03-15.json
  ~/Documents/daily/2026-03-15-summary.md
  ~/Documents/daily/context/ENG-123.md
  ~/Documents/daily/context/TASK-1.md

Skipped (still referenced by other plans):
  ~/Documents/daily/context/ENG-456.md  ← referenced by 2026-03-18.json
```

If there are no context files and no summary, note that too.

## Step 4 — Dry-run or confirm

**If `--dry-run`:** Print the deletion plan from Step 3 and stop. Do not delete anything. Print:
```
Dry run complete. No files were deleted.
```

**Otherwise:** Print the deletion plan and ask:
```
Delete these files? (yes/no)
```

If the user answers anything other than `yes` or `y`, abort and print:
```
Aborted. No files were deleted.
```

## Step 5 — Delete

Delete all files marked as "safe to delete" in Step 3. Do not touch protected context files.

Confirm:
```
Deleted 3 file(s).

Skipped (still referenced):
  context/ENG-456.md  ← referenced by 2026-03-18.json
```
