---
description: "Execute approved ticket plan end-to-end with hard gates."
agent: "build"
---

Ticket: `$1`

First, immediately print exactly one line:
`BUILD_START: $1`

Then execute this workflow strictly in order.

1. Resolve ticket context

- Use `linear_get_issue` to fetch full issue details for `$1`.
- Keep `ticket_identifier` (eg `DIR-123`) and derive `ticket_slug` from title.

2. Announce names before creation

- Before running any git command that creates resources, print exactly these two lines:
  `BRANCH_NAME: <branch>`
  `WORKTREE_PATH: <worktree_path>`
- After printing both lines, then proceed to creation commands.

3. Create branch + worktree

- Branch name format: `feature/<ticket_identifier>-<ticket_slug>` (slug: lowercase kebab, max 50 chars).
- Determine `repo_name` dynamically from repo root directory name.
- Worktree path format is strict and must be: `../worktrees/<repo_name>/<ticket_identifier>-<ticket_slug>` relative to repo root.
- Create parent folder first: `mkdir -p ../worktrees/<repo_name>`
- Create worktree from `origin/main` using the strict path:
  `git fetch origin && git worktree add -b <branch> ../worktrees/<repo_name>/<ticket_identifier>-<ticket_slug> origin/main`
- After this point, ALL file edits and shell commands must run inside `<worktree_path>`.
- Immediately verify and print these lines:
  - `WORKTREE_CREATED: true`
  - `WORKTREE_BRANCH: <branch_from_git_rev_parse>`
- Safety check: if `<worktree_path>` does not start with `../worktrees/<repo_name>/`, STOP and print `BUILD_ABORTED: invalid worktree path`.
- If verification fails, STOP and print `BUILD_ABORTED: worktree creation failed`.

3b. Safety gate: never modify or commit on main

- Before any edit/commit action, check current branch in the active working directory.
- If branch is `main` or `master`, STOP and print `BUILD_ABORTED: on main branch`.

4. Implement approved plan

- Implement the approved plan from planning phase for this ticket.
- Keep changes scoped to ticket requirements and existing project conventions.

5. Reviewer/Builder loop (max 3 cycles)

- Run up to 3 review cycles.
- In each cycle, delegate code review to `oracle` as a subagent with this rubric:
  a) security and robustness
  b) extensible architecture
  c) established code patterns and style
- If reviewer says LGTM, stop loop.
- Otherwise, apply fixes and continue to next cycle.
- Hard stop at 3 cycles with a brief report if issues remain.

6. Verification (must pass before ship)

- Detect available scripts from `package.json` and run these in this order when present:
  a) format (`npm run format`)
  b) lint (`npm run lint`)
  c) type-check (`npm run type-check` or `npm run typecheck`)
  d) tests (`npm run test`)
- If any command fails, fix and re-run until all required checks pass.
- If no code changes exist after implementation (`git status --short` has no tracked changes), STOP and print `BUILD_ABORTED: no code changes`.

7. Commit, push, PR

- Create commit(s) with clear message(s) referencing `$1`.
- Before commit, re-check branch. If branch is `main` or `master`, STOP and print `BUILD_ABORTED: commit attempted on main`.
- Push branch: `git push -u origin <branch>`
- Create PR using `gh pr create`.
  - PR title must include `$1`.
  - PR body must summarize implementation, review loop result, and verification commands run.
- Capture PR URL into `<pr_url>` and print: `PR_CREATED: <pr_url>`
- If commit, push, or PR creation fails, STOP and print `BUILD_ABORTED: ship step failed`.

8. Do not change Linear issue state

- Never call `linear_update_issue` for ticket status transitions in this workflow.
- GitHub-Linear integration is the source of truth for status movement.

9. Cleanup worktree only

- Return to repo root worktree and remove created worktree:
  `git worktree remove <worktree_path>`
- DO NOT delete local or remote branch.
- Print `WORKTREE_REMOVED: true` after successful removal.

10. Final output (required)
    Print exactly these fields at the end:

- `Ticket:` <ticket_identifier>
- `Branch:` <branch>
- `PR:` <pr_url>
- `WorktreeRemoved:` true
- `Checks:` <comma-separated checks that passed>
