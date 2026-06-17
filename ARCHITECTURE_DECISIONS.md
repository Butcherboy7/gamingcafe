# Architecture Decisions — Grill-Me Session (2026-06-17)

> Every decision below was challenged, defended, and locked during an adversarial
> architecture review. This document is the **single source of truth** for the
> data model and system design. Any future code must conform to these decisions.

---

## Decision 1: Pre-Generated Slots + Specific PC Selection

**Context:** The original `models.py` used `TSTZRANGE` with a PostgreSQL
`ExcludeConstraint` on bookings — a dynamic gap-computation model suited for
flexible-duration systems like car rentals.

**Decision:** Remove `TSTZRANGE` and `ExcludeConstraint`. Add a `Slots` table.
A nightly cron pre-generates a row for every `(PC, date, time_block)` combination.

**Why:**
- Availability query becomes `SELECT WHERE status = 'free' AND cafe_id = X AND date = Y` — fast, indexable, cacheable in Redis.
- The customer experience is a visual grid of **specific PCs** at **specific times** (movie-ticket model, not airline-upgrade model).
- The admin dashboard is a simple grid read, not real-time gap analysis.
- `UNIQUE(pc_id, date, start_time)` makes slot generation idempotent — cron can run twice safely.

**Tradeoff accepted:** Storage. 20 PCs × 28 half-hour blocks × 7 days = 3,920 rows per café per week. PostgreSQL handles this trivially.

---

## Decision 2: Hybrid PCTier with Per-PC Override

**Context:** `PCTier` holds bulk pricing and specs. But individual PCs may differ
(e.g., one PC has a broken speaker, priced ₹10 cheaper).

**Decision:** Keep `PCTier` for default `hourly_rate_paise` and `specs` JSON.
Add `hourly_rate_override` (nullable) on `PhysicalPC`. Slot generation uses
`COALESCE(pc.hourly_rate_override, tier.hourly_rate_paise)`.

**Admin UI requirement:** Show a warning badge on any PC whose override differs
from its tier's default price.

---

## Decision 3: CafeSchedule Table (Normalized Weekly Hours)

**Context:** Indian gaming cafés have different hours on weekdays vs weekends
(e.g., 2pm on school days, 10am on Saturday).

**Decision:** New `CafeSchedule` table with columns:
- `cafe_id` (FK)
- `day_of_week` (0–6, Monday–Sunday)
- `opening_time` (TIME)
- `closing_time` (TIME)

Seven rows per café. Slot generation reads the schedule for the target day.

**Future:** `CafeSpecialHours` table for holidays and one-off closures
(Diwali, exams, emergencies).

---

## Decision 4: Split Authorization Model

**Context:** Both `User.role` and `CafeStaff.role` existed, creating ambiguity
about the source of truth for café-level permissions.

**Decision:**
- `User.system_role` = `customer | superadmin` — platform-level identity.
- `CafeStaff.role` = `owner | manager | staff` — café-level authorization, scoped per café.

**Middleware logic:**
- Platform endpoints check `User.system_role`.
- Café admin endpoints query `CafeStaff` for `(user_id, cafe_id)`.
- Removing a staff member deletes their `CafeStaff` row; `User.system_role` is unaffected. No sync bugs.

---

## Decision 5: User Model — Required Fields

| Field               | Type                                    | Notes                          |
|---------------------|-----------------------------------------|--------------------------------|
| `name`              | String, nullable                        | From Google OAuth              |
| `profile_picture_url` | String, nullable                      | From Google OAuth              |
| `system_role`       | Enum (`customer`, `superadmin`)         | Default: `customer`            |
| `trust_score`       | Integer                                 | Default: 100                   |
| `is_banned`         | Boolean                                 | Default: false                 |
| `ban_until`         | DateTime, nullable                      | Auto-unban after this time     |

---

## Decision 6: One-to-Many Payments

**Context:** UPI retries (first attempt fails, user retries with card) and
session extensions require multiple payment events per booking.

**Decision:** Separate `Payments` table with `booking_id` FK. Many payments → one booking.

**Fields:**
- `razorpay_order_id` (unique)
- `razorpay_payment_id` (unique, nullable)
- `amount_paise`
- `status` (created / authorized / captured / failed / refund_pending / refunded)
- `is_upi` (Boolean — triggers extended lock TTL)
- `refund_id`, `refund_status`, `refund_amount_paise`

**Why separate table:** Razorpay webhook handler touches `Payments` row. Admin
actions touch `Booking` row. Same-row access = potential PostgreSQL row-level
lock contention under load. Separate tables = separate lock domains.

---

## Decision 7: BookingSlots Junction Table (Multi-Slot Bookings)

**Context:** A 2-hour session on 30-minute slots = 4 slots. How does one booking
reference multiple slots?

**Decision:** Junction table `BookingSlots(booking_id, slot_id)`.

**Analogy:**
- `Booking` = the e-commerce **order** (one per session, one QR code, one payment flow)
- `BookingSlots` = the **line items**
- `Slots` = the **inventory**

**Checkout UX:** User selects 4 consecutive slots on PC 7 → backend creates
1 Booking + 4 BookingSlots rows → 1 Razorpay order → 1 QR code → 1 SMS.

**Why not group_id on multiple bookings:** Breaks the many-to-one Payment→Booking
relationship. A single Razorpay payment cannot cleanly point to 4 separate
booking rows without a phantom grouping entity.

---

## Decision 8: WebhookLog for Idempotency

**Decision:** `WebhookLog` table with `razorpay_event_id` as primary key.

**Processing flow:**
1. Webhook arrives → attempt INSERT into WebhookLog.
2. If `IntegrityError` (duplicate) → return 200 OK, skip processing.
3. If INSERT succeeds → process the event (update Payment, confirm Booking).

**Crash safety:** If server crashes after inserting WebhookLog but before
confirming the booking, the log entry exists but the booking isn't confirmed.
Detectable on startup via a reconciliation query.

---

## Decision 9: BookingEvents Audit Log

**Decision:** Append-only table. Every booking status transition writes a row.

**Fields:**
- `booking_id` (FK)
- `from_status`, `to_status`
- `triggered_by` (enum: user / admin / system / webhook)
- `actor_id` (nullable UUID — which user or admin)
- `timestamp`
- `metadata` (JSON — e.g., refund amount, reason)

**Purpose:** Dispute resolution. When a user says "I paid but my booking shows
cancelled," query BookingEvents for the full immutable state history.

---

## Decision 10: Google Sign-in for MVP Auth

**Decision:** Google OAuth via NextAuth.js (frontend) + python-jose JWT (backend).
No phone OTP for MVP.

**Why:** One-tap login. Target user (18–28 year old Indian gamer) has Google
signed in on their phone. OTP requires SMS delivery, DLT registration,
per-message cost, DND filter debugging — a full day of work for worse UX.

**Tradeoff accepted:** Cannot match users by phone number for walk-in
reconciliation. QR code is the identity token instead.

**Future path:** Optional phone verification post-login. Addable without
breaking auth architecture.

---

## Decision 11: Public Browsing, Auth Required for Booking

**Decision:**
- `GET /cafes` and `GET /cafes/{id}/slots` → **public** (no auth required).
- `POST /bookings` → **requires authentication**.

Frontend shows login prompt when unauthenticated user taps "Book This Slot,"
then continues the flow after auth completes.

---

## Final Aligned Schema (All Tables)

```
Users
Cafes
CafeSchedule
CafeSpecialHours       (future — holidays/closures)
CafeStaff
PCTiers
PhysicalPCs
Slots
Bookings
BookingSlots           (junction: booking ↔ slots)
Payments
BookingEvents          (audit log)
WebhookLog             (idempotency)
```

---

## Café Model — Fields to Add

| Field                 | Type              | Notes                            |
|-----------------------|-------------------|----------------------------------|
| `slot_duration_minutes` | Integer (30/60) | Per-café slot block size         |
| `latitude`            | Float             | For proximity sorting            |
| `longitude`           | Float             | For proximity sorting            |
| `city`                | String            | For search by city               |
| `address`             | String            | Display                          |
| `images`              | JSON array        | Café photos (URLs)               |
| `is_active`           | Boolean           | Soft-availability toggle         |
| `deleted_at`          | DateTime, nullable| Soft delete                      |
| `no_show_policy`      | JSON              | Per-café configuration           |
| `cancellation_policy` | JSON              | Per-café configuration           |

---

## Current Codebase State (as of this session)

| File               | Status                                                            |
|--------------------|-------------------------------------------------------------------|
| `app/models/models.py` | **Needs rewrite** — has TSTZRANGE, missing Slots/Payments/etc |
| `app/database.py`  | OK — async engine, needs `pool_size` tuning later                 |
| `app/main.py`      | Minimal — health check only                                       |
| `app/schemas.py`   | **Needs rewrite** — based on old TSTZRANGE model                  |
| `docker-compose.yml` | Has Postgres + Redis, **missing** API and worker services        |

---

## Next Step

Rewrite `models.py` to match every decision in this document. Then proceed
with the numbered build order (to be generated in next session).
