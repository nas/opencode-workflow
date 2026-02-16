---
description: "Approve, modify, or cancel a pending ticket plan."
agent: "build"
---

Input:

- `$1` may be one of: `approve`, `modify`, `cancel`, `1`, `2`, `3`, `help`, or empty.
- `$ARGUMENTS` may include modification notes after `modify`.

## Find the pending ticket

Look through the conversation history for the most recent `PENDING_BUILD_TICKET: <ID>` line.
Use the last occurrence only (last one wins).

## Rules

1. If no `PENDING_BUILD_TICKET` marker exists in the conversation, reply exactly:
   `No pending plan found. Run /tickets first, then /tickets <number>.`

2. If `$1` is empty or `help`, print exactly these four lines and stop:

   ```
   Decision options:
   1) approve
   2) modify
   3) cancel
   Run /decision 1 | /decision 2 <notes> | /decision 3
   ```

3. Map numeric aliases: `1` => `approve`, `2` => `modify`, `3` => `cancel`.

4. If `$1` is not one of `approve|modify|cancel|1|2|3|help`, reply exactly:
   `Invalid decision. Use /decision or /decision 1|2|3`

5. **If decision is `cancel`**: reply exactly `Plan cancelled. No build executed.`

6. **If decision is `modify`**:
   - If no notes after `modify`, reply exactly: `Please provide change notes: /decision modify <notes>`
   - If notes are provided, revise the plan for `<ID>` by applying those notes.
   - End with exactly:
     ```
     PENDING_BUILD_TICKET: <ID>
     Choose one: /decision approve | /decision modify <notes> | /decision cancel
     ```

7. **If decision is `approve`**: print these two lines, then proceed to the Build Workflow below:
   ```
   BUILD_APPROVED_TICKET: <ID>
   PLAN_APPROVED_EXECUTING_BUILD
   ```

---

## Build Workflow (runs only on approve)

### Step 1: Resolve ticket context

- Use `linear_get_issue` to fetch full issue details for `<ID>`.
- Keep `ticket_identifier` (e.g. `DIR-123`) and derive `ticket_slug` from the title (lowercase kebab-case, max 50 chars).

### Step 2: Announce names before creation

Print exactly:

```
BRANCH_NAME: <branch>
WORKTREE_PATH: <worktree_path>
```

Then proceed to creation.

### Step 3: Create branch + worktree

- Branch name format: `feature/<ticket_identifier>-<ticket_slug>`
- Determine `repo_name` dynamically from the repo root directory name.
- Worktree path: `../worktrees/<repo_name>/<ticket_identifier>-<ticket_slug>` (relative to repo root).
- Run:
  ```
  mkdir -p ../worktrees/<repo_name>
  git fetch origin
  git worktree add -b <branch> ../worktrees/<repo_name>/<ticket_identifier>-<ticket_slug> origin/main
  ```
- After creation, ALL file edits and shell commands MUST run inside the worktree path.
- Verify and print:
  ```
  WORKTREE_CREATED: true
  WORKTREE_BRANCH: <branch from git rev-parse>
  ```
- Safety check: if worktree path does not start with `../worktrees/<repo_name>/`, STOP and print `BUILD_ABORTED: invalid worktree path`.
- If verification fails, STOP and print `BUILD_ABORTED: worktree creation failed`.

### Step 3b: Safety gate

Before any edit/commit, check the current branch in the active working directory.
If branch is `main` or `master`, STOP and print `BUILD_ABORTED: on main branch`.

### Step 4: Implement approved plan

- Implement the plan from the planning phase for this ticket.
- Keep changes scoped to ticket requirements and existing project conventions.

### Step 5: Review loop (max 3 cycles)

- Run up to 3 review cycles.
- In each cycle, delegate code review to a subagent (e.g. `@explore` or equivalent) with this rubric:
  a) security and robustness
  b) extensible architecture
  c) established code patterns and style
- If reviewer says LGTM, stop the loop.
- Otherwise, apply fixes and continue to next cycle.
- Hard stop at 3 cycles with a brief report if issues remain.

### Step 6: Verification (must pass before ship)

- Detect available scripts from `package.json` and run in order when present:
  a) `npm run format`
  b) `npm run lint`
  c) `npm run type-check` (or `npm run typecheck`)
  d) `npm run test`
- If any command fails, fix and re-run until all pass.
- If no code changes exist (`git status --short` has no tracked changes), STOP and print `BUILD_ABORTED: no code changes`.

### Step 7: Commit, push, PR

- Create commit(s) with clear message(s) referencing `<ID>`.
- Before commit, re-check branch. If `main` or `master`, STOP and print `BUILD_ABORTED: commit attempted on main`.
- Push: `git push -u origin <branch>`
- Create PR: `gh pr create`
  - Title must include `<ID>`.
  - Body must summarize implementation, review loop result, and verification commands run.
- Print: `PR_CREATED: <pr_url>`
- If commit, push, or PR creation fails, STOP and print `BUILD_ABORTED: ship step failed`.

### Step 8: Do not change Linear issue state

- Never call `linear_update_issue` for ticket status transitions.
- GitHub-Linear integration handles status movement.

### Step 9: Cleanup worktree

- Return to the repo root and remove the worktree:
  `git worktree remove <worktree_path>`
- Do NOT delete the local or remote branch.
- Print `WORKTREE_REMOVED: true` after successful removal.

### Step 10: Final output (required)

Print exactly these fields at the end:

```
Ticket: <ticket_identifier>
Branch: <branch>
PR: <pr_url>
WorktreeRemoved: true
Checks: <comma-separated checks that passed>
```
