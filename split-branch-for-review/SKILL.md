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
- Aim for stacked branches of about 800 changed lines each, counting additions plus deletions and excluding clearly generated files.
- A layer is valid only if it does not break the current system by itself.
- Prefer fewer coherent branches over mechanical line-count slicing.
- If a cohesive change is larger than 800 lines but splitting would make intermediate branches unsafe or confusing, say so.

## Workflow

1. Verify the repository state:
   - Confirm the current directory is inside a git repository.
   - Identify the current branch, target branch, and merge base.
   - Note whether there are uncommitted, staged, or untracked changes.

2. Measure the diff:
   - Run `scripts/diff-line-budget.sh {target-branch}` if available.
   - Inspect `git diff --stat {target-branch}...HEAD`.
   - Inspect the actual diff, commit list, and changed file groups.
   - Exclude generated/vendor/build artifacts from the review-size budget, but mention them if they affect risk.

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

5. Recommend a split:
   - If total counted changes are near or below 800 lines and the work is cohesive, recommend one PR.
   - If changes are large or span multiple domains, propose a stack of branches.
   - Keep each proposed layer reviewable, independently safe, and roughly 800 counted lines where possible.
   - Explain any layer that exceeds the budget.

## Output Format

Respond with:

```
## Verdict
[Keep as one PR / Split recommended / Split not worth it]

## Diff Size
- Target branch: ...
- Merge base: ...
- Counted lines: ...
- Generated or ignored lines: ...
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
Use `scripts/diff-line-budget.sh {target-branch} [max-lines]` to count changed lines against the target branch while excluding common generated files. The helper is advisory; still inspect the diff before recommending a split.
