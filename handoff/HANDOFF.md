# HANDOFF.md — Gaming Café Booking Platform

**Last updated:** 2026-06-13
**Session summary:** Solidified the core product assumptions to optimize for minimum UX friction (Phone/OTP checkouts) and zero-headache admin walk-ins (QR code scanning). We architected the multi-tenant PostgreSQL schema to support tier-based inventory using `tstzrange` overlaps, and successfully built the SQLAlchemy 2.0 `models.py` file implementing these rules. We also created a `bridge.md` file to expose Antigravity's internal workflows to your external planning LLM.

## Current System State

**What works right now:**

- The foundational database logic (SQLAlchemy models) for users, multi-tenant cafes, staff audit trails, inventory tiers, and time-range bookings is completely written.
- The external LLM integration bridge is documented.
  **What is broken or incomplete:**
- No API routes, schemas, or services exist yet. The models are purely conceptual in code.
  **What was NOT done that was planned:**
- We haven't generated the Alembic migrations yet because we paused to ensure you understood the Postgres `ExcludeConstraint` logic first.

## Architecture as of now

A multi-tenant SaaS backend using FastAPI + SQLAlchemy 2.0 + PostgreSQL. The system uses shared-schema isolation (via `cafe_id` on all tables) and leverages Postgres' native `btree_gist` and `tstzrange` capabilities to handle complex time-bucket overlaps mathematically at the database layer.

**Key files:**

- `bridge.md`: Exposes the `gc_*` slash commands so the external LLM can trigger Antigravity's specific learning/building modules.
- `architecture/data_models.md`: The complete documentation of the MVP relational schema and technical tradeoffs.
- `app/models/models.py`: The production-ready SQLAlchemy 2.0 DeclarativeBase models containing our entities and constraints.

## Database State

**Migration status:** Not initialized. Alembic has not been run yet.
**Tables that exist (in code):** `users`, `cafes`, `cafe_staff`, `pc_tiers`, `physical_pcs`, `bookings`.
**Pending schema changes:** Need to manually ensure `CREATE EXTENSION IF NOT EXISTS btree_gist;` is added to the first Alembic migration script before applying it, otherwise the `ExcludeConstraint` on `bookings` will fail.

## Environment

- Requires PostgreSQL 15+ (for modern range types and indexing).
- Requires the `btree_gist` extension to be enabled in the target database.

## Next Steps (in order)

1. **Initialize Alembic:** Run `alembic init`, configure `env.py` to point to our models, and generate the first migration.
2. **Inject Extension:** Manually edit the generated migration to execute `CREATE EXTENSION IF NOT EXISTS btree_gist;` before table creation.
3. **Pydantic Validation:** Move to Step 1 of the `/gc_build` workflow and create the `app/schemas/` models for validating incoming booking requests.
4. **Service Layer:** Build the business logic in `app/services/` that handles the row-level locking (`SELECT FOR UPDATE`) when creating a booking.

## Concepts Uzair learned this session

- **GiST Indexes & ExcludeConstraints:** How PostgreSQL can mathematically prevent two rows from having overlapping time ranges (`tstzrange` using the `&&` operator) while simultaneously checking equality on another column (the PC ID).
- **Advisory / Row-Level Locking:** Why we must lock the `pc_tiers` row when booking a tier-based slot to prevent race conditions during the `COUNT(*)` check.

## Decisions made this session

- **Auth:** Guest Checkout (Phone/OTP) / Email. Phone implicitly becomes the account to drastically reduce funnel friction.
- **Inventory:** Tier-based (e.g., VIP Rig) rather than Specific PC booking to prevent fragmentation and optimize utilization.
- **Booking Time:** Dynamic time buckets (min 1 hr, 30-min increments) stored natively as ranges, rather than rigid 1-hour chunks.
- **Admin Workflow:** QR-code based instant check-in. The Admin scans the user's booking and makes 1 click to auto-assign a physical PC.

## Open questions

- Are we going to use Fast2SMS exclusively for OTPs, or will we need a fallback provider?
- How will we handle payment gateway (Razorpay) webhooks intersecting with the row-level locks during booking confirmation?

## Warnings for next session

Do not blindly run `alembic upgrade head` on the first migration without adding the GiST extension first. It will throw an obscure Postgres syntax error on the `bookings` table constraint.
