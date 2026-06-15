---
description: End-to-end pre-deploy verification
---
1. /critic on all modified files.
2. /secure on all API routes/endpoints modified.
3. /ux on all UI components modified (skip if backend-only project).
4. Run the project's build/compile command. Fix any errors.
5. Output final summary: risks found, fixes applied, build status.
6. Update HANDOFF.md with ship status.
