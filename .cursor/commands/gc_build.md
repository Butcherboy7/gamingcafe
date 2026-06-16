---
description: Implement approved spec for Gaming Café Booking Platform following strict layering rules
---
1. Read the approved specification or existing design files.
2. Confirm the 8-step build sequence (Rule 1) is being followed. Check concepts first.
3. Write/generate code in this exact order:
   - **Validation schemas**: `app/schemas/` (Pydantic).
   - **Data models & migrations**: `app/models/` (SQLAlchemy) and run Alembic to generate migration.
   - **Business logic**: `app/services/` (No HTTP/FastAPI imports).
   - **Route handlers**: `app/api/routes/` (HTTP wrappers calling services).
   - **Background workers**: `app/workers/` (APScheduler jobs).
   - **UI views**: Next.js components (PWA/Admin).
4. Run syntax/compilation checks: e.g. python lint/run, or Next.js build.
5. Ask Uzair to explain what was built.
6. Update `handoff/HANDOFF.md` and `project_logs/gaming_cafe/implementation_log.md`.
