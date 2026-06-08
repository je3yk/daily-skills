---
name: planning-session
description: "Run a planning session for one or more Linear tasks: analyze each, draft a plan, run planning poker with the user, and post the result back to Linear. Usage: /planning-session {LINEAR-ID}... [--ratio N]"
---

Plan and estimate one or more Linear tasks through a structured planning-poker ritual.

## Input

Arguments: one or more Linear issue IDs, optionally followed by `--ratio N` to override the default MD-to-SP ratio.

Examples:
- `/planning-session STY-101`
- `/planning-session STY-101 STY-102 STY-103`
- `/planning-session STY-101 STY-102 --ratio 2.0`

Defaults:
- **MD-to-SP ratio:** 1 MD ≈ 2.4 SP. Used to derive an MD figure from the SP estimate as a size reference.
- **SP scale:** Fibonacci — 1, 2, 3, 5, 8, 13. Capped at 13; anything bigger means the task must be split.
- **SP semantics:** SP captures difficulty and risk; MD is just a size reference.

If no Linear IDs are provided, print usage and stop.

If Linear MCP is not available, print `Linear MCP unavailable. Cannot fetch tasks. Skill aborted.` and stop.

## Step 1 — Setup

Fetch all task titles in parallel from Linear. Then print the run queue:

```
🎲 Planning session — {N} tasks, MD-to-SP ratio: 1 MD ≈ {R} SP

Queue:
  1. STY-101 — {title}
  2. STY-102 — {title}
  ...

Starting with STY-101...
```

If the current working directory is not a git repository, print a one-line warning before starting:

> ⚠️ Not in a git repo — code exploration will be skipped. Estimates will be based on Linear descriptions only.

Process tasks sequentially (Steps 2–9 per task). On any per-task failure, record the task in the appropriate outcome bucket and continue with the next task. Do not abort the whole run unless the MCP itself becomes unavailable mid-run.

## Step 2 — Fetch and pre-checks

For the current task:

1. **Fetch from Linear** — title, description, comments, parent, children, labels, current estimate, current status. Do **not** show the current estimate to yourself during analysis; surface it only at reveal time (Step 7).

2. **Parent-with-children check.** If the task has sub-issues, do not plan it. Print and skip:
   > 🚫 STY-101 has sub-issues. Plan the sub-issues individually instead. Skipping.

3. **Sub-issue context.** If the task has a parent, fetch the parent's title and description as background context for analysis. Do not modify the parent.

4. **Prior-planning detection.** Scan comments for any comment whose body starts with `## 📋 Planning session` (the canonical header from this skill). If found, summarize the prior planning (date, estimate, key plan points) and ask:
   > Prior planning found for STY-101 ({date}, {N} SP). What now? **re-plan / skip / update**

   - `skip` → record as skipped, move to next task.
   - `update` → go to Step 9.
   - `re-plan` → continue with full ritual.

## Step 3 — Description quality gate

Decide whether the available information (description, comments, parent context) is enough to draft a plan you would be willing to defend in the poker round.

If not, ask the user clarifying questions in chat:

> ❓ STY-101 description is thin. Before I can plan this, I need:
> 1. {question}
> 2. {question}

The user's answers will be captured in the Linear comment under a `### Planning assumptions` section — recorded as assumptions, not as facts from the original reporter.

If the description is sufficient, skip this step.

## Step 4 — Light code exploration

Skip if not in a git repo.

Run a small number of greps and file reads in the current working directory to ground the technical interpretation. Goal: confirm where the work likely lives, not start implementing it. Stop as soon as you have enough to estimate.

## Step 5 — Draft and review (Phase 1)

Pick the analysis framing based on the task type:
- **Bug** → identify likely source files and the suspected mechanism.
- **Feature** → identify integration points and affected layers.
- **Refactor / chore** → identify scope boundaries and risks.
- **Research / spike** → identify the questions to answer; propose a timebox.

Present the draft to the user:

```
## STY-101 — {title}

**Technical interpretation**
{2–4 sentences, framed per task type}

**Draft plan**
1. {step}
2. {step}
...

Anything to adjust?
```

Loop on user adjustments until the plan is approved.

## Step 6 — Lock and form estimate (transition to Phase 2)

Once the user approves the plan:

1. **Form your SP estimate privately.** Base it on difficulty and risk of the locked plan. Use the Fibonacci scale (1, 2, 3, 5, 8, 13). Derive an MD figure using the ratio.
2. **Do not adjust this estimate after seeing the user's number.** Your role is to defend the estimate honestly, not to converge with the user.
3. **Too-big check.** If your estimate would exceed 13 SP, halt this task per Step 8's too-big handling — do not proceed to poker.

Then say explicitly:

> ✅ Plan locked. I've formed my estimate. What's yours? (SP — Fibonacci: 1, 2, 3, 5, 8, 13)

## Step 7 — Poker reveal

Wait for the user's number. Accept lenient input (`5`, `5 SP`, `5sp` all valid).

Reveal:

```
🎲 You: {N} SP
🎲 Agent: {M} SP (~{X} MD)
🎲 Current Linear estimate: {existing or "none"}
```

**MD formatting:** one decimal place; never display less than `0.5 MD`.

**If both numbers match exactly** → go to Step 8 (confirm and post).

**If any difference** → go to disagreement resolution.

### Disagreement resolution

Each side shares rationale. Either side may revise on the Fibonacci scale. Argue on equal footing:
- Defend your estimate if the user's argument is "feels like more" with no new information.
- Concede if presented with a fact you didn't know (e.g. hidden coupling, prior incident, team-specific risk).

Soft cap: **2 rounds of back-and-forth.** After 2 rounds, if still disagreeing, default to the **higher** of the two current numbers and add a flag to the comment rationale:

> Estimation uncertain — settled on the higher value after 2 discussion rounds.

If at any point an estimate above 13 SP is proposed (by either side), apply the too-big handling in Step 8.

## Step 8 — Confirm and post

### Too-big handling

If the agreed estimate would exceed 13 SP at any point, halt this task:

> 🚫 STY-101 is too big to estimate as one unit (>13 SP). Proposed split:
> 1. {sub-task}
> 2. {sub-task}
> ...
>
> Please split in Linear and re-run planning. Skipping.

Record as too-big and move to next task.

Exception: if the user explicitly insists on estimating anyway, cap at 13 and add `⚠️ Likely larger than 13 SP` to the rationale.

### Normal posting

Once an estimate is settled, present the full draft for confirmation:

```
Ready to post on STY-101:

Estimate: {N} SP (~{M} MD)
{If Linear had a different existing estimate:} Will overwrite existing Linear estimate {X} SP.

Comment preview:
---
## 📋 Planning session — YYYY-MM-DD

### Technical interpretation
{...}

### Draft plan
1. {...}

{If clarifying questions were asked in Step 3:}
### Planning assumptions
- {...}

### Estimate: **{N} SP** (~{M} MD)
**Rationale:** {why this estimate — difficulty, risk, complexity drivers, and what would move it up or down}

{Only if disagreement happened:}
**Discussion notes:** Agent initially estimated {X}, user estimated {Y}. Settled on {N} because {decisive argument}.
---

Post? (y/n)
```

Voice: first-person plural ("we estimated", "our rationale") — this is a joint output.

On `y`:
1. Update the Linear estimate metadata first.
2. If the estimate update succeeds, post the comment.
3. If the estimate update fails, do not post the comment; record as failed.
4. If the comment post fails after the estimate succeeded, record as partial; do not retry.

On `n`: record as skipped.

Print the inter-task summary line:

```
✅ STY-101 — posted ({N} SP, ~{M} MD)
   {i} of {total} complete. Moving to STY-102...
```

## Step 9 — Update path

Reached when the user picks `update` on prior-planning detection.

1. Show the prior planning summary.
2. Ask: `What's changed since the prior planning? (free text)`
3. Capture the delta. Do **not** re-run estimation. Do **not** touch the Linear estimate metadata.

Exception: if the user explicitly states the estimate should change, confirm the new number (one round, no poker ritual), then update both the metadata and include it in the update comment.

Post a new comment with header `## 📋 Planning update — YYYY-MM-DD` containing the delta and any new assumptions. Do **not** edit the prior comment.

Inter-task summary line:

```
✏️  STY-101 — update posted
   {i} of {total} complete. Moving to STY-102...
```

## Step 10 — End-of-run summary

After all tasks have been processed, print:

```
🎲 Planning session complete.

✅ STY-101 — 5 SP (~2.1 MD)
✅ STY-102 — 8 SP (~3.3 MD)
✏️  STY-103 — update posted
⏭️  STY-104 — skipped (prior planning, you chose skip)
🚫 STY-105 — too big, recommend split
❌ STY-106 — failed to fetch from Linear

Total planned: {n} tasks, {sum} SP (~{sum} MD)
```

Outcome icons:
- `✅` posted (re-plan or new planning)
- `✏️` update posted
- `⏭️` skipped by user choice
- `🚫` halted (parent-with-children, too-big)
- `❌` failed (fetch error, estimate-update failure)
- `⚠️ partial` if estimate updated but comment failed

"Total planned" counts only `✅` outcomes.

## User abort

If the user aborts mid-run, print the partial summary listing tasks already updated in Linear and tasks not yet processed. Do not attempt to roll back posted comments.
