---
name: split-branch-for-review
description: "Analyzes branch diffs before opening a PR and recommends whether the work should be split into smaller stacked review branches. Use when preparing to push or open a PR, when the user asks if a branch is too large, or when they provide a target branch to compare against. Usage: /split-branch-for-review {target-branch}"
---

# Split Branch for Review

Analyze the current branch against a required target branch and decide whether the changes should be split into smaller stacked branches before opening a PR.

## Input

The user must provide the target branch used for comparison:

```
/split-branch-for-review main
/split-branch-for-review origin/main
```

If no target branch is provided, ask for it and stop until the user answers.

## Principles

- Do not push, rebase, cherry-pick, reset, or rewrite history unless the user explicitly asks.
- Treat the target branch as the review base. Compare the current branch with the merge base of `HEAD` and the target branch.
- Count additions plus deletions per file. Exclude clearly auto-generated files from the review-size budget (see **Line budget** below).
- A layer is valid only if it does not break the current system by itself.
- Prefer fewer coherent branches over mechanical line-count slicing.
- Layer mixing (data model + API + UI in one PR) matters more than raw line count in the smaller tiers.
- When splitting is warranted, aim for stacked branches of roughly 800 counted lines each, introducing one layer of change per branch where possible.
- If a cohesive change is larger than 800 counted lines but splitting would make intermediate branches unsafe or confusing, say so.

## Line budget

**Counted lines** = additions + deletions, excluding auto-generated files.

Always exclude from the count:

- Vendor, lockfiles, build artifacts, and other paths matched by `scripts/diff-line-budget.sh`
- Database migrations and schema migration folders (for example `**/migrations/**`, `**/db/migrate/**`, Alembic `versions/`, Django `migrations/`)

If you are unsure whether a path is auto-generated, ask the developer which paths or globs to treat as generated for this repo before finalizing the verdict.

### Size tiers

Use counted lines (after exclusions) together with layer mixing to decide whether to split:

| Tier | Counted lines | Default split stance |
|------|---------------|----------------------|
| Perfect | `< 100` | Probably keep as one PR unless multiple independent layers are mixed |
| Good | `100–199` | Unlikely to need a split unless multiple layers are mixed |
| Okay | `200–799` | Acceptable size; actively check whether a safer, layer-by-layer split is possible |
| Large | `≥ 800` | Must evaluate splitting into smaller stacked branches, each introducing one layer where feasible |

Tier guidance is advisory: a 150-line PR that mixes migrations, API, and UI may still warrant a split; a 900-line cohesive refactor with no safe intermediate layers may stay as one PR with an explicit rationale.

## Workflow

1. Verify the repository state:
   - Confirm the current directory is inside a git repository.
   - Identify the current branch, target branch, and merge base.
   - Note whether there are uncommitted, staged, or untracked changes.

2. Measure the diff:
   - Run `scripts/diff-line-budget.sh {target-branch}` if available.
   - Inspect `git diff --stat {target-branch}...HEAD`.
   - Inspect the actual diff, commit list, and changed file groups.
   - Apply the **Line budget** exclusions (including migrations). If any changed file might be generated but is not covered by defaults, ask the developer before locking the tier.
   - Map counted lines to a **size tier** (Perfect / Good / Okay / Large).

3. Classify the work into change groups:
   - Data model, migrations, schemas, generated clients.
   - Shared infrastructure, utilities, or refactors.
   - Backend/API behavior.
   - Frontend/UI behavior.
   - Tests and fixtures.
   - Cleanup, docs, or follow-up removals.

4. Test each possible layer for safety:
   - It compiles, tests, and linting can pass on that branch alone.
   - Existing behavior remains compatible until later layers land.
   - New code paths are gated, unused, or fully wired within the same layer.
   - Database or persisted-data changes are backward-compatible.
   - Public APIs, contracts, and imports do not leave dependents broken.

5. Recommend a split (use size tier + layer mixing):
   - **Perfect / Good:** Default to one PR when the work is a single layer. Split only when layers are mixed or a stacked sequence is clearly safer for review.
   - **Okay:** Prefer one PR for cohesive single-layer work, but state whether a layer-by-layer stack would improve reviewability without breaking intermediate branches.
   - **Large:** Default to evaluating a split. Propose a stack unless you can justify one PR (single layer, no safe split, or split would be more confusing).
   - When splitting, keep each proposed layer reviewable, independently safe, and roughly ≤ 800 counted lines where possible.
   - Explain any proposed layer that exceeds 800 counted lines.

## Output Format

Respond with:

```
## Verdict
[Keep as one PR / Split recommended / Split not worth it]

## Diff Size
- Target branch: ...
- Merge base: ...
- Counted lines: ...
- Size tier: Perfect | Good | Okay | Large
- Generated or ignored lines: ... (list paths/patterns excluded, including migrations)
- Working tree state: ...

## Proposed Stack
1. branch-name-foundation
   Scope: ...
   Estimated counted lines: ...
   Safety invariant: ...
   Suggested verification: ...

2. branch-name-feature
   Scope: ...
   Estimated counted lines: ...
   Safety invariant: ...
   Suggested verification: ...

## Notes
- Risks, coupling, generated files, or reasons not to split.
- Suggested next commands only if the user asks to perform the split.
```

## Optional Helper
Use `scripts/diff-line-budget.sh {target-branch}` to count changed lines against the target branch while excluding common generated files and migrations. The script prints the matching **size tier**. The helper is advisory; still inspect the diff and layer mixing before recommending a split.
