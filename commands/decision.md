---
description: "Plan decision for pending ticket: approve, modify, or cancel."
---

Input:

- `$1` may be one of: `approve`, `modify`, `cancel`, `1`, `2`, `3`.
- `$ARGUMENTS` may include modification notes after `modify`.

Find the most recent `PENDING_BUILD_TICKET: <ID>` marker in this session.

Rules:

1. If no pending marker exists, reply exactly: `No pending plan found. Run /tickets <ticket_number> first.`
2. Safety default: if `$1` is empty, print exactly these four lines and stop (never execute build):
   `Decision options:`
   `1) approve`
   `2) modify`
   `3) cancel`
   `Run /decision 1 | /decision 2 <notes> | /decision 3`
3. If `$1` is exactly `help`, print the same four lines from rule 2 and stop.
4. Map numeric choices as aliases:
   - `1` => `approve`
   - `2` => `modify`
   - `3` => `cancel`
5. If `$1` is not one of `approve|modify|cancel|1|2|3|help`, reply exactly: `Invalid decision. Use /decision or /decision 1|2|3`.
6. If decision is `approve`:
   - Print exactly: `PLAN_APPROVED_EXECUTING_BUILD`
   - Immediately execute `/_build_from_plan <ID>`.
7. If decision is `modify`:
   - If no notes are provided, reply exactly: `Please provide change notes: /decision modify <notes>`.
   - If notes are provided, continue planning for `<ID>` by applying those notes and updating the plan.
   - End with exactly these two lines:
     `PENDING_BUILD_TICKET: <ID>`
     `Choose one: /decision approve | /decision modify <notes> | /decision cancel`
8. If decision is `cancel`, reply exactly: `Plan cancelled. No build executed.`
