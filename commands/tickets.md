---
description: "List Todo tickets or select one to plan."
agent: "build"
---

Behavior depends on argument:

- If no argument is provided (`$1` is empty): list tickets (Mode A).
- If a number is provided (`$1` like `3`): select that ticket and plan it (Mode B).

## Mode A: list tickets (no argument)

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

Output for Mode A:

- If no issues match, output exactly: `No Todo tickets found in current cycles.`
- Otherwise output ONLY a numbered list where each line is exactly:
  `1. IDENTIFIER — Todo — Title`
- After the list, print exactly this line:
  `To start working on a ticket, run: /tickets <number>`

## Mode B: select and plan ticket (numeric argument)

1. Look at the conversation history for the most recent numbered ticket list produced by a previous `/tickets` invocation.
2. Find the line starting with `$1.` and extract the ticket identifier (e.g. `DIR-123`).
3. If the list is not found or the number is invalid, reply exactly: `Invalid selection. Run /tickets first to see the list, then /tickets <number>.`
4. If extraction succeeds, fetch the full ticket details using `linear_get_issue` with the extracted identifier.

### Planning phase

5. Read the ticket description, comments, and any linked resources.
6. Ask only the minimum clarification questions needed (zero if the ticket is clear enough).
7. Present a concrete implementation plan covering:
   - Files to create or modify
   - Key logic changes
   - Any dependencies or risks
8. If there are open decisions that block implementation, list them and ask the user to resolve them before approving.

### End of planning output (mandatory)

9. End your response with exactly these two lines as the final output:

```
PENDING_BUILD_TICKET: <IDENTIFIER>
Choose one: /decision approve | /decision modify <notes> | /decision cancel
```

Postcondition check: before finishing, verify your final two lines match the format above. If not, correct them.

### Important rules

- Do NOT start building or writing code in this command. Planning only.
- Do NOT proceed to build if the user sends a plain text message asking to implement. Remind them to run `/decision approve`.
