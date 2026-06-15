# Mistake Log
> Patterns of errors and antipatterns caught during development
> Purpose: Identify recurring weaknesses and eliminate them

---

## Mistake format
```
### Pattern: {name}
**First seen:** {date}
**Times seen:** {count}
**Description:** {what the mistake looks like}
**Why it happens:** {root cause — usually a misconception}
**Correct approach:** {what to do instead}
**Status:** recurring / improving / resolved
```

---

## Pattern: Vibe Coding
**First seen:** {date}
**Times seen:** 0
**Description:** Generating or pasting code without being able to explain what it does
**Why it happens:** Speed pressure, AI assistance makes it easy to get working code without understanding
**Correct approach:** Stop. Read the code line by line. Explain each line out loud. If stuck, ask for explanation before continuing.
**Status:** watch

---

## Pattern: Missing Error Handling
**First seen:** {date}
**Times seen:** 0
**Description:** Writing happy path only, not handling the failure case
**Why it happens:** Optimism. "This won't fail." It will.
**Correct approach:** For every operation that can fail (DB, Redis, HTTP, payment), ask "what happens if this returns an error?"
**Status:** watch

---

## Pattern: Sync in Async
**First seen:** {date}
**Times seen:** 0
**Description:** Using blocking calls (requests.get, time.sleep, sync DB) inside async functions
**Why it happens:** Not understanding the event loop. Looks like it works until load.
**Correct approach:** In async functions: use httpx not requests, asyncio.sleep not time.sleep, async SQLAlchemy not sync
**Status:** watch

