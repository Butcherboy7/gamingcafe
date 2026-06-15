# Database Data Models
> All tables, relationships, and design decisions
**Project:** Gaming Café Booking Platform (SaaS)
**Last updated:** June 2026

## MVP Schema Design & Relational Plan

### 1. `cafes` (Tenants)
**Purpose:** Multi-tenant SaaS isolation.
- `id`: UUID (Primary Key)
- `name`: String
- `timezone`: String (Crucial for time-based bookings, e.g., 'Asia/Kolkata')
- `created_at`: Timestamp

### 2. `users` (Global)
**Purpose:** Global player accounts. Users are not locked to a single café.
- `id`: UUID (Primary Key)
- `email`: String (Unique)
- `auth_provider`: String (e.g., 'google', 'email')
- `created_at`: Timestamp

### 3. `pc_tiers` (Inventory Definition)
**Purpose:** Tier-based inventory (no specific PC bookings).
- `id`: UUID (Primary Key)
- `cafe_id`: UUID (Foreign Key to `cafes`, Indexed)
- `name`: String (e.g., "VIP Rig", "Standard")
- `total_quantity`: Integer (Physical count of PCs in this tier)
- `hourly_rate_paise`: Integer (Price in lowest denomination)

### 4. `physical_pcs` (For Admin Assignment)
**Purpose:** To track actual physical machines for walk-in assignments.
- `id`: UUID (Primary Key)
- `cafe_id`: UUID (Foreign Key to `cafes`)
- `tier_id`: UUID (Foreign Key to `pc_tiers`)
- `pc_number`: String (e.g., "PC-12")
- `status`: Enum (online, maintenance)

### 5. `bookings` (The Core Ledger)
**Purpose:** Central transaction and scheduling record.
- `id`: UUID (Primary Key)
- `cafe_id`: UUID (Foreign Key, Indexed) -> *For multi-tenant isolation at the row level*
- `user_id`: UUID (Foreign Key, Indexed)
- `tier_id`: UUID (Foreign Key, Indexed)
- `booking_time`: `tstzrange` (Timestamp with Timezone Range) -> *Postgres native feature for overlapping intervals*
- `status`: Enum (pending, confirmed, active, completed, cancelled)
- `qr_code_token`: String (Unique, Indexed) -> *Cryptographically secure URL-safe string*
- `assigned_pc_id`: UUID (Foreign Key to `physical_pcs`, Nullable) -> *Set by admin upon scan*
- `created_at`: Timestamp

---

## Technical Tradeoffs & Solutions

### 1. Multi-Tenancy Enforcement
**Approach:** Row-Level Isolation via `cafe_id`.
Every table except `users` has a `cafe_id`. All API queries and database operations must include `WHERE cafe_id = X` (enforced at the FastAPI dependency layer or via Postgres Row-Level Security).
**Tradeoff:** Shared Database / Shared Schema is the cheapest and most maintainable approach for MVP SaaS. We lose the strict data isolation of a schema-per-tenant architecture, but it drastically reduces schema migration complexity.

### 2. Handling Overlaps & Double Bookings
**Approach:** `tstzrange` with Row-Level Locking (`SELECT FOR UPDATE`).
Because we are using *Tier-based* booking, we cannot simply use a naive Postgres Exclusion Constraint on a single PC. Instead, when a booking request arrives:
1. Start transaction.
2. `SELECT * FROM pc_tiers WHERE id = X FOR UPDATE;` (Locks the tier to prevent race conditions).
3. Query overlapping bookings: `SELECT COUNT(*) FROM bookings WHERE tier_id = X AND status = 'confirmed' AND booking_time && tstzrange(requested_start, requested_end);` (Using the `&&` overlap operator with a GiST index on `booking_time`).
4. If `count < tier.total_quantity`, `INSERT` booking and commit.
**Tradeoff:** Locking the tier row slightly reduces write concurrency for that specific tier, but local booking volume will never hit levels where this lock contention causes bottlenecks. It mathematically eliminates double-bookings.

### 3. Secure QR Code Modeling
**Approach:** `qr_code_token` column using `secrets.token_urlsafe(32)`.
When a booking is confirmed, we generate a 32-character URL-safe random string and save it to `qr_code_token`. The QR code displayed to the user encodes `https://admin.domain.com/claim?token=XYZ`. The admin scans it, and the system looks up the booking via the indexed token.
**Tradeoff:** Simple and stateless. However, we must ensure the token is marked 'used' (or we only accept tokens where booking status is `confirmed` and not `active`) to prevent replay attacks (e.g., someone screenshotting the QR and using it again).

### 4. Overbooking Protection (Admin Check-in)
Once a user arrives and the QR is scanned, the Admin assigns a `physical_pc_id`. Here, we *can* and *should* use a PostgreSQL Exclusion Constraint:
`ALTER TABLE bookings ADD CONSTRAINT exclude_overlapping_pcs EXCLUDE USING gist (assigned_pc_id WITH =, booking_time WITH &&) WHERE (assigned_pc_id IS NOT NULL);`
This guarantees at the DB engine level that an admin can never accidentally assign two people to "PC-12" at the exact same time.
