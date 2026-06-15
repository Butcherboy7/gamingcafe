---
description: Generate a technical specification specifically for the Gaming Café Booking Platform before writing code
---
1. Read `handoff/HANDOFF.md` to align with the current state of the project.
2. Confirm stack context: FastAPI, async SQLAlchemy, PostgreSQL, Redis, Next.js, Razorpay, Fast2SMS.
3. Generate the specification document including:
   - **Affected Data Models**: SQLAlchemy models, constraints (e.g. unique PC/date/start_time), denormalized fields.
   - **API Endpoints**: Request/response Pydantic validation schemas, error payloads, and endpoint routes.
   - **Background Worker**: Cron jobs, worker tasks (APScheduler) separate from the API process.
   - **Critical Checkpoints**: Redis lock status, webhook idempotency checks, UPI pending state.
4. STOP. Do not write implementation code. Present the spec and wait for user approval.
