---
description: Compact summary of agent reasoning from start to finish of current task
---
Generate a compact reasoning trace of everything done this session.
Format:

```
## Recap: [Task Name]

### Decision Log
1. [Decision] — why: [rationale]
2. ...

### What Was Built
- [file]: [what it does]

### Patterns Worth Remembering
- [Pattern]: [when to reuse this]

### Mistakes & Corrections
- [What went wrong] → [How it was fixed]

### Key Takeaways
- [Insight a senior engineer would note]
```

Rules:
- Max 30 lines total. Dense, not narrative.
- Focus on WHY decisions were made, not WHAT code was written.
- Include any "aha moments" — solutions that should be reused.
- If a pattern should be permanent, suggest adding it to project AGENTS.md.
