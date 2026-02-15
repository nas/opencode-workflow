---
description: "List Todo tickets and optionally select one."
agent: "build"
---

Behavior depends on argument:

- If no argument is provided (`$1` is empty): list tickets.
- If a number is provided (`$1` like `3`): select that ticket from the most recent `/tickets` list in this session and start planning.

Mode A: list tickets (no argument)
Use the Linear MCP tools with these exact steps:

1. Call `linear_list_teams` with `includeArchived: false`.
2. For each returned team, call `linear_list_cycles` with that team id and `type: "current"`.
3. For each current cycle found, call `linear_list_issues` with:
   - `assignee: "me"`
   - `state: "Todo"`
   - `cycle: <current cycle id or name from step 2>`
   - `team: <team id or key from step 1>`
   - `includeArchived: false`
   - `orderBy: "updatedAt"`
   - `limit: 250`
4. Merge and deduplicate issues by issue id.
5. Sort by `updatedAt` descending and keep the first 20.

Output requirements:

- If no issues match, output exactly: `No Todo tickets found in current cycles.`
- Otherwise output ONLY a numbered list where each line is exactly:
  `1. IDENTIFIER — Todo — Title`
- After the list, print exactly this line:
  `To start working on a ticket, run: /tickets <ticket_number>`

Mode B: select ticket (numeric argument provided)

1. Find the line starting with `$1.` from the latest `/tickets` list in this session.
2. Extract the ticket identifier (for example `DIR-123`).
3. If extraction fails, reply exactly: `Invalid selection. Run /tickets and choose a valid number.`
4. If extraction succeeds, execute `/_plan_ticket <IDENTIFIER>`.
