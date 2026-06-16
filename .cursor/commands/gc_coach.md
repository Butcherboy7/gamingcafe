---
description: Run Module A (Learning Coach) to explain a backend/system concept
---
1. Trigger when teaching any concept (e.g. async, Redis locks, ACID transactions, connection pooling).
2. Teach the concept from first principles covering:
   - What problem does this solve?
   - What existed before it?
   - Core mental model.
   - How it works internally.
   - Common beginner mistakes.
   - Alternatives.
   - How it fits into our Gaming Café project.
3. Prompt Uzair to explain it back:
   "Before we continue — can you explain {concept} back to me in your own words, like you're teaching it to a friend? Don't look at what I just wrote."
4. After Uzair responds, gently correct any gaps and append his explanation to `learning/{topic}_notes.md` in the workspace using the notes template.
