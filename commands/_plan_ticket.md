---
description: "Plan a selected ticket and gate build on approval."
agent: "build"
---

Ticket selected: `$ARGUMENTS`

You are in PLANNING phase for this ticket. Be deterministic.

Do this strictly:

1. Fetch ticket details and relevant context.
2. Ask only the minimum clarification questions needed.
3. Present a concrete implementation plan.
4. If there are open decisions, do NOT execute build yet. Resolve decisions first.
5. End with exactly these two lines:
   `PENDING_BUILD_TICKET: $ARGUMENTS`
   `Choose one: /decision approve | /decision modify <notes> | /decision cancel`

Approval handling rule (critical):

- Do not start build from a plain text message.
- Build starts only when the user runs `/decision approve`.
