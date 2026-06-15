---
description: Scaffold the approved spec — models, logic, routes, views
---
1. Run /spec output as context (or read existing spec).
2. Detect project stack from config files.
3. Generate in order: validation schemas → data models/migrations → business logic → route handlers → UI components.
4. Each concern in a separate file. No business logic in route handlers.
5. Run the project's migration/build command. Confirm success before continuing.
6. Update HANDOFF.md with what was built.
