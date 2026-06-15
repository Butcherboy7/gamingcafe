---
description: Run pre-deploy verification and validation for Gaming Café Booking Platform
---
1. Run `/gc_critic` on all modified code files.
2. Run `/gc_secure` on all modified or new API endpoints.
3. Run `/ux` on any modified Next.js screens (Admin panel/Customer PWA).
4. Run Alembic migrations check: ensure all model changes have migrations and run `alembic upgrade head`.
5. Run the project tests (if they exist).
6. Output final summary: risks found, fixes applied, build status, and Alembic version.
7. Update `handoff/HANDOFF.md` with the new ship state.
