# 🎮 Gaming Café Booking Platform — Complete Antigravity Execution Plan

> **Stack:** FastAPI + async SQLAlchemy + Alembic + PostgreSQL 16 + Redis 7 + Next.js 14 + shadcn/ui + Razorpay + Fast2SMS
> **Timeline:** 22 working days
> **Workflow:** Claude (planning) → Antigravity Fast Mode (execution) → HANDOFF.md (continuity)

---

## ⚙️ GROUND RULES BEFORE YOU TOUCH ANTIGRAVITY

### Model Selection (non-negotiable)
| Task Type | Model |
|---|---|
| Payment logic, booking engine, Redis locking, webhooks | **Opus** |
| CRUD, middleware, schema, migrations, UI screens | **Sonnet** |
| Docker configs, env files, deployment, HANDOFF updates | **Flash** |

### Prompt Rules
1. **One atomic feature per prompt.** Never combine booking + payment in one prompt.
2. **Always paste HANDOFF.md at the top of every session.** No exceptions.
3. **If a prompt exceeds ~300 lines of expected output, split it.**
4. **After every session: update HANDOFF.md before closing Antigravity.**
5. **Never ask Antigravity to "also add X" mid-prompt. Finish the prompt, commit, new prompt.**

### Session Structure (every single session)
```
1. Open Antigravity
2. Paste HANDOFF.md content at top of prompt
3. Write the prompt for this session's feature
4. Execute
5. Test manually
6. Fix bugs (Sonnet for targeted fixes)
7. Git commit with descriptive message
8. Update HANDOFF.md
9. Close
```

---

## 📁 PROJECT STRUCTURE (Set This Up Before Anything)

```
/cafe-booking/
├── backend/
│   ├── app/
│   │   ├── api/
│   │   │   ├── routes/
│   │   │   │   ├── auth.py
│   │   │   │   ├── cafes.py
│   │   │   │   ├── slots.py
│   │   │   │   ├── bookings.py
│   │   │   │   ├── payments.py
│   │   │   │   ├── admin.py
│   │   │   │   └── superadmin.py
│   │   ├── core/
│   │   │   ├── config.py
│   │   │   ├── security.py
│   │   │   ├── redis.py
│   │   │   └── database.py
│   │   ├── models/
│   │   │   └── (all SQLAlchemy models)
│   │   ├── schemas/
│   │   │   └── (all Pydantic schemas)
│   │   ├── services/
│   │   │   ├── otp.py
│   │   │   ├── slot_generator.py
│   │   │   ├── booking.py
│   │   │   ├── payment.py
│   │   │   ├── notification.py
│   │   │   └── refund.py
│   │   ├── workers/
│   │   │   ├── scheduler.py       ← SEPARATE PROCESS
│   │   │   ├── expiry_worker.py
│   │   │   └── slot_gen_worker.py
│   │   └── main.py
│   ├── alembic/
│   ├── tests/
│   ├── .env
│   ├── Dockerfile
│   └── requirements.txt
├── admin-panel/                   ← Next.js (café admin)
├── customer-app/                  ← Next.js PWA (customers)
├── docker-compose.yml
└── HANDOFF.md
```

---

## 🗄️ COMPLETE FINAL DATABASE SCHEMA
> Give this to Antigravity verbatim in Prompt #2. This is the single source of truth.

```python
# models/user.py
class User(Base):
    __tablename__ = "users"
    id: UUID (PK, default uuid4)
    phone: str (unique, indexed)
    name: str | None
    role: Enum("customer", "cafe_admin", "superadmin")
    profile_index: int (default 0)          # 0 or 1 — shared phone support
    no_show_count: int (default 0)
    is_banned: bool (default False)
    ban_until: datetime | None
    trust_score: float (default 1.0)
    email: str | None                        # for account recovery
    created_at: datetime
    deleted_at: datetime | None

# models/cafe.py
class Cafe(Base):
    __tablename__ = "cafes"
    id: UUID (PK)
    name: str
    city: str
    address: str
    latitude: float
    longitude: float
    opening_time: time
    closing_time: time
    slot_duration_minutes: int              # 30 or 60
    gst_number: str | None
    images: list[str]                       # JSON array of URLs
    is_active: bool (default True)
    admin_id: UUID (FK → users)
    no_show_policy: JSON                    # {grace_minutes: 15, mode: "end_at_original"}
    cancellation_policy: JSON               # {allowed_before_minutes: 30, penalty_paise: 2000}
    allow_walk_ins: bool (default True)
    created_at: datetime
    deleted_at: datetime | None

class CafeSpecialHours(Base):
    __tablename__ = "cafe_special_hours"
    id: UUID (PK)
    cafe_id: UUID (FK → cafes)
    date: date
    is_closed: bool
    opening_time: time | None
    closing_time: time | None
    reason: str | None                      # "Diwali", "Maintenance"

# models/pc.py
class PC(Base):
    __tablename__ = "pcs"
    id: UUID (PK)
    cafe_id: UUID (FK → cafes)
    label: str                              # "PC 1", "High-End 3"
    type: Enum("standard", "high_end", "vip")
    specs: JSON | None                      # {gpu: "RTX 4070", ram: "32GB"}
    is_active: bool (default True)
    position_x: int | None                  # for layout map
    position_y: int | None
    created_at: datetime

# models/slot.py
class Slot(Base):
    __tablename__ = "slots"
    __table_args__ = (
        UniqueConstraint("pc_id", "date", "start_time"),  # idempotent generation
    )
    id: UUID (PK)
    pc_id: UUID (FK → pcs)
    cafe_id: UUID (FK → cafes)              # denormalized
    date: date (indexed)
    start_time: time
    end_time: time
    price_paise: int                        # snapshot at generation time
    status: Enum("free", "locked", "booked", "blocked")
    generated_at: datetime

# models/booking.py
class Booking(Base):
    __tablename__ = "bookings"
    id: UUID (PK)
    user_id: UUID (FK → users)
    slot_id: UUID (FK → slots)
    cafe_id: UUID (FK → cafes)             # denormalized for query perf
    status: Enum("pending", "confirmed", "cancelled", "expired",
                 "no_show", "completed", "refund_pending", "refunded")
    payment_id: UUID | None (FK → payments)
    version: int (default 0)               # optimistic locking
    qr_token: str                          # TOTP-style, regenerated every 5 min
    qr_base_secret: str                    # HMAC secret for this booking
    expires_at: datetime                   # when pending booking auto-dies
    arrived_at: datetime | None
    is_walk_in: bool (default False)
    created_at: datetime
    group_id: UUID | None                  # for group bookings

class BookingEvent(Base):
    __tablename__ = "booking_events"
    id: UUID (PK)
    booking_id: UUID (FK → bookings)
    from_status: str
    to_status: str
    triggered_by: str                      # "user", "admin", "system", "webhook"
    triggered_by_id: UUID | None
    metadata: JSON | None                  # razorpay_payment_id, reason, etc.
    created_at: datetime

# models/payment.py
class Payment(Base):
    __tablename__ = "payments"
    id: UUID (PK)
    booking_id: UUID (FK → bookings)
    razorpay_order_id: str (unique)
    razorpay_payment_id: str | None (unique)
    amount_paise: int
    status: Enum("created", "captured", "failed", "refund_initiated",
                 "refund_processed", "refund_failed")
    payment_method: str | None             # "upi", "card", "netbanking"
    is_upi: bool (default False)           # extended lock flag
    razorpay_refund_id: str | None
    refund_amount_paise: int | None
    webhook_received_at: datetime | None
    created_at: datetime

class WebhookLog(Base):
    __tablename__ = "webhook_logs"
    id: UUID (PK)
    razorpay_event_id: str (unique)        # idempotency key
    event_type: str
    payload: JSON
    processed: bool (default False)
    processed_at: datetime | None
    error: str | None
    received_at: datetime

# models/payout.py
class Payout(Base):
    __tablename__ = "payouts"
    id: UUID (PK)
    cafe_id: UUID (FK → cafes)
    period_start: date
    period_end: date
    gross_amount_paise: int
    platform_fee_paise: int
    net_amount_paise: int
    status: Enum("pending", "processing", "paid", "failed")
    payment_reference: str | None
    paid_at: datetime | None
    created_at: datetime

# models/waitlist.py
class Waitlist(Base):
    __tablename__ = "waitlist"
    id: UUID (PK)
    slot_id: UUID (FK → slots)
    user_id: UUID (FK → users)
    notified: bool (default False)
    notified_at: datetime | None
    expires_at: datetime                   # 10 min to act on notification
    created_at: datetime

# models/group_booking.py
class GroupBooking(Base):
    __tablename__ = "group_bookings"
    id: UUID (PK)
    organizer_user_id: UUID
    cafe_id: UUID
    slot_date: date
    start_time: time
    end_time: time
    status: Enum("pending", "confirmed", "cancelled")
    razorpay_order_id: str | None
    total_amount_paise: int
    created_at: datetime
```

---

## 🚀 PHASE 1 — FOUNDATION (Days 1–3)

### Prompt 1 — Project Scaffold
**Model: Sonnet | Est. time: 2 hours**

```
Build a FastAPI project with the following exact structure and config:

Stack:
- FastAPI (latest)
- async SQLAlchemy 2.0 with asyncpg driver
- Alembic for migrations
- Redis via aioredis
- Pydantic v2 for schemas
- python-jose for JWT
- passlib for hashing
- python-dotenv

Requirements:
1. Docker Compose with services: api, postgres, redis, worker
   - api and worker are separate containers from same image
   - worker runs scheduler.py not main.py
2. app/core/config.py — Settings class using pydantic-settings, reads .env
3. app/core/database.py — async engine, AsyncSession factory, get_db dependency
4. app/core/redis.py — aioredis pool, get_redis dependency, health check function
5. app/main.py — FastAPI app, CORS (allow all for dev), include routers, startup/shutdown events
6. requirements.txt with pinned versions
7. .env.example with all required vars:
   DATABASE_URL, REDIS_URL, JWT_SECRET, JWT_REFRESH_SECRET,
   FAST2SMS_API_KEY, RAZORPAY_KEY_ID, RAZORPAY_KEY_SECRET,
   RAZORPAY_WEBHOOK_SECRET, ENVIRONMENT (dev/prod)
8. Dockerfile (multi-stage, slim python image)
9. Basic health check endpoint GET /health that checks DB + Redis connectivity

Do NOT create any models or routes yet. Foundation only.
```

---

### Prompt 2 — Complete DB Schema + Migrations
**Model: Sonnet | Est. time: 2 hours**

```
[PASTE HANDOFF.md HERE]

Create all SQLAlchemy async models and the initial Alembic migration.

[PASTE THE COMPLETE SCHEMA FROM ABOVE]

Requirements:
1. All models in separate files under app/models/
2. app/models/__init__.py imports all models (required for Alembic autogenerate)
3. All UUIDs use uuid4 default
4. All datetimes are timezone-aware UTC
5. Add indexes:
   - slots: (cafe_id, date, status)
   - bookings: (cafe_id, status, created_at)
   - bookings: (user_id, status)
   - webhook_logs: (razorpay_event_id) UNIQUE
6. Run alembic init, configure env.py to use our async engine
7. Generate initial migration with alembic revision --autogenerate
8. Verify migration SQL looks correct (paste it in comments)

After this prompt: run docker compose up and verify tables exist with \dt in psql.
```

---

### Prompt 3 — OTP Auth System
**Model: Opus | Est. time: 3 hours**

```
[PASTE HANDOFF.md HERE]

Build the complete OTP authentication system.

Endpoints:
POST /auth/send-otp
  - Body: {phone: str, profile_index: int = 0}
  - Validate Indian phone format (10 digits, starts with 6-9)
  - Rate limit: max 3 OTP requests per phone per 10 minutes (Redis counter)
  - Generate 6-digit OTP
  - Store in Redis: key="otp:{phone}:{profile_index}" value="{otp}:{attempt_count}"  TTL=300s
  - Send via Fast2SMS transactional route (NOT promotional — DND compliance)
  - Return: {message: "OTP sent", expires_in: 300}
  - In dev/test environment: return OTP in response (skip SMS)

POST /auth/verify-otp
  - Body: {phone: str, otp: str, profile_index: int = 0}
  - Max 3 wrong attempts then lock (increment attempt_count in Redis value)
  - On success: delete Redis key
  - Find or create User record
  - Issue: access_token (JWT, 15 min expiry) + refresh_token (JWT, 7 days, stored in Redis)
  - Return: {access_token, refresh_token, user: {id, phone, name, role}}

POST /auth/refresh
  - Body: {refresh_token: str}
  - Validate against Redis (key="refresh:{user_id}")
  - Issue new access_token
  - Rotate refresh_token (delete old, store new)

POST /auth/logout
  - Delete refresh token from Redis
  - Requires valid access_token

Shared phone support:
  - profile_index 0 and 1 allowed per phone
  - Creates separate User records linked by phone

Security requirements:
  - OTP is constant-time compared (no timing attacks)
  - JWT contains: sub (user_id), role, profile_index, exp
  - JWT_SECRET and JWT_REFRESH_SECRET are different keys
```

---

### Prompt 4 — Role Middleware + Auth Guards
**Model: Sonnet | Est. time: 1 hour**

```
[PASTE HANDOFF.md HERE]

Build authentication dependencies for FastAPI route protection.

Requirements:
1. get_current_user(token: str = Depends(oauth2_scheme)) → User
   - Decode JWT, fetch user from DB, check not banned
   - Raise 401 if invalid, 403 if banned

2. Three role guard dependencies:
   - require_customer → user.role in ["customer", "cafe_admin", "superadmin"]
   - require_cafe_admin → user.role in ["cafe_admin", "superadmin"]
   - require_superadmin → user.role == "superadmin"

3. Ownership validators (as utility functions, not dependencies):
   - assert_user_owns_booking(booking_id, current_user)
   - assert_admin_owns_cafe(cafe_id, current_user)

4. Rate limiting middleware using Redis:
   - Sliding window: 100 req/min per IP for general routes
   - 10 req/min per IP for booking creation
   - Return 429 with Retry-After header

All dependencies use async DB session properly.
```

---

## 🏗️ PHASE 2 — CAFÉ & SLOT ENGINE (Days 4–6)

### Prompt 5 — Café + PC CRUD
**Model: Sonnet | Est. time: 2 hours**

```
[PASTE HANDOFF.md HERE]

Build Café and PC management endpoints.

Café endpoints (superadmin only):
POST /superadmin/cafes — create café
GET /superadmin/cafes — list all cafés
PATCH /superadmin/cafes/{cafe_id} — update
DELETE /superadmin/cafes/{cafe_id} — soft delete (set deleted_at)
POST /superadmin/cafes/{cafe_id}/assign-admin — assign a user as cafe_admin

PC endpoints (cafe_admin):
POST /admin/cafes/{cafe_id}/pcs — add PC
PATCH /admin/pcs/{pc_id} — update (label, type, is_active, specs)
DELETE /admin/pcs/{pc_id} — soft delete

Public endpoints:
GET /cafes — list active cafés, sorted by distance if lat/lng query params provided
  - Query params: city (filter), lat, lng (sort by distance using Haversine formula)
  - Cache result in Redis for 5 minutes per city
GET /cafes/{cafe_id} — café detail with PC list

Special hours (cafe_admin):
POST /admin/cafes/{cafe_id}/special-hours — set date as closed or custom hours
GET /admin/cafes/{cafe_id}/special-hours — list upcoming special hours
DELETE /admin/special-hours/{id} — remove

Validation:
- opening_time must be before closing_time
- slot_duration_minutes must be 30 or 60
- PC label must be unique within a café
```

---

### Prompt 6 — Slot Generation Worker (CRITICAL)
**Model: Opus | Est. time: 3 hours**

```
[PASTE HANDOFF.md HERE]

Build the slot generation system. This is critical infrastructure.

Requirements:

1. app/workers/slot_gen_worker.py — standalone script, NOT embedded in FastAPI
   - Uses APScheduler with a Redis-based distributed lock
   - Lock key: "slot_gen_lock", TTL: 10 minutes
   - If lock not acquired (another instance running), skip and log — never run twice
   - Runs daily at 23:00 IST (17:30 UTC) to generate next day's slots
   - Also runs at startup to generate today's slots if missing

2. app/services/slot_generator.py — core generation logic:
   generate_slots_for_cafe(cafe_id, date) → int (slots created):
   
   - Fetch café with opening_time, closing_time, slot_duration_minutes
   - Check cafe_special_hours for this date:
     - If is_closed: skip entirely
     - If custom hours: use those instead
   - For each active PC in café:
     - Generate time slots from open to close
     - For each slot: UPSERT with ON CONFLICT (pc_id, date, start_time) DO NOTHING
     - Price from PC type: standard=pc.hourly_rate, calculated per slot_duration
   - Return count of slots created
   - Entire operation is ONE database transaction

3. Timezone handling:
   - All internal times are UTC
   - Slot generation uses pytz/zoneinfo with 'Asia/Kolkata'
   - When generating for "today IST", calculate correct UTC offset

4. Partial regen trigger (for when café updates hours mid-day):
   POST /admin/cafes/{cafe_id}/regenerate-slots
   - Only for cafe_admin of that café
   - Acquires same Redis lock
   - Generates slots for today + next 7 days
   - Upsert only — never delete existing booked slots

5. Generation status:
   - Redis key: "slot_gen_status:{cafe_id}:{date}" = "generating" | "complete"
   - Set to "generating" before start, "complete" after
   - GET /cafes/{cafe_id}/slots returns {status: "loading"} if still generating

6. Worker runs in the separate "worker" Docker container.
   The FastAPI "api" container never runs APScheduler.
```

---

### Prompt 7 — Slot Query API + Redis Caching
**Model: Opus | Est. time: 2 hours**

```
[PASTE HANDOFF.md HERE]

Build the slot viewing API with Redis caching.

GET /cafes/{cafe_id}/slots
  Query params: date (default today IST), include_pcs (list of pc_ids to filter)
  
  Logic:
  1. Check slot_gen_status Redis key — if "generating" return {status: "loading"}
  2. Check Redis cache: key="slots:{cafe_id}:{date}" TTL=60s
  3. If cache miss: query DB joining slots → pcs, group by PC
  4. Return structure:
     {
       cafe_id, date,
       pcs: [{
         pc_id, label, type, specs,
         slots: [{
           slot_id, start_time, end_time, price_paise, status,
           is_past: bool  ← block if start_time < now IST
         }]
       }],
       current_occupancy: int,  ← from Redis counter
       total_pcs: int
     }
  5. Write to Redis cache
  
  Cache invalidation:
  - On any booking status change for a slot in this café+date: delete cache key
  - On slot generation complete: delete cache key
  - Invalidation function in app/core/redis.py: invalidate_slot_cache(cafe_id, date)

Occupancy tracking:
  - Redis key: "occupancy:{cafe_id}" = count of confirmed bookings right now
  - Increment on check-in (mark_arrived), decrement on checkout/complete
  - Exposed in slot API response

GET /cafes/{cafe_id}/slots/{slot_id} — single slot detail (no cache, fresh)
```

---

## 💳 PHASE 3 — BOOKING ENGINE (Days 7–11)

> ⚠️ This phase is the heart of the system. Use Opus for everything. Split every prompt. Test every edge case manually before moving to next prompt.

### Prompt 8 — Redis Slot Locking
**Model: Opus | Est. time: 2 hours**

```
[PASTE HANDOFF.md HERE]

Build the Redis slot locking service. This is the race condition prevention layer.

app/services/slot_lock.py:

async def acquire_slot_lock(slot_id: UUID, user_id: UUID, redis, payment_method: str = None) → bool:
  - Key: "slot_lock:{slot_id}"
  - Value: JSON {user_id, acquired_at, payment_method}
  - TTL:
    * Standard (card/netbanking): 120 seconds (2 min)
    * UPI detected: 2700 seconds (45 min) — UPI pending state protection
    * Default (unknown method at lock time): 120 seconds, extend to 2700 on UPI detection
  - Use Redis SET NX (set if not exists) — atomic operation
  - Also update slot.status = "locked" in DB atomically
  - Return True if lock acquired, False if slot already locked

async def release_slot_lock(slot_id: UUID, redis):
  - Delete Redis key
  - Update slot.status = "free" in DB
  - Trigger slot cache invalidation

async def extend_lock_for_upi(slot_id: UUID, redis):
  - Called when Razorpay returns UPI payment method
  - Update TTL to 2700 on existing lock key
  - Update payment.is_upi = True

async def get_lock_info(slot_id: UUID, redis) → dict | None:
  - Return lock info or None if not locked

async def check_redis_health(redis) → bool:
  - Ping Redis, return False if down
  - Used as guard before any lock operation

Failure behavior when Redis is down:
  - Return 503 with body: {error: "Booking service temporarily unavailable", retry_after: 30}
  - Never fall through to DB-only path (prevents double bookings)
```

---

### Prompt 9 — Booking Creation Flow
**Model: Opus | Est. time: 4 hours**

```
[PASTE HANDOFF.md HERE]

Build the complete booking creation flow. This is the most critical endpoint in the system.

POST /bookings/create
Body: {slot_id: UUID, payment_method_hint: str | None}

Full flow (every step must succeed or entire operation rolls back):

Step 1 — Validation:
  - User is not banned
  - User daily booking count < 3 (configurable per café, default 3)
  - Slot exists, is "free", date is today or future, start_time > now IST
  - No existing pending/confirmed booking for this user on this slot

Step 2 — Redis health check:
  - If Redis down: return 503 immediately

Step 3 — Acquire slot lock:
  - acquire_slot_lock(slot_id, user_id, redis, payment_method_hint)
  - If False: return 409 {error: "Slot just got booked, please select another"}

Step 4 — Create DB records (single transaction):
  - Create Booking: status=pending, expires_at=now+120s (or now+2700s for UPI hint)
  - Set booking.qr_base_secret = secrets.token_hex(32)
  - Set booking.qr_token = generate_qr_token(booking.id, booking.qr_base_secret)
  - Create Payment: status=created
  - Write BookingEvent: {from: null, to: "pending", triggered_by: "user"}
  - Update slot.status = "locked"

Step 5 — Create Razorpay order:
  - amount = slot.price_paise
  - receipt = f"booking_{booking.id}"
  - notes = {booking_id: str, cafe_id: str, slot_id: str}
  - If Razorpay call fails:
    * Release slot lock
    * Delete booking + payment records
    * Return 502 {error: "Payment gateway unavailable, please retry"}

Step 6 — Update payment record with razorpay_order_id

Step 7 — Return:
  {
    booking_id, slot details, cafe details,
    razorpay_order_id, razorpay_key_id,
    amount_paise, expires_at,
    qr_token  ← show immediately so user can screenshot
  }

Additional endpoint:
GET /bookings — list user's bookings (active first, then past), paginated
GET /bookings/{booking_id} — single booking detail with fresh QR token
  - QR token refresh: generate_qr_token uses HMAC(booking_id + floor(now/300))
    so it rotates every 5 minutes automatically

POST /bookings/{booking_id}/cancel (customer)
  - Validate ownership + policy (cafe.cancellation_policy.allowed_before_minutes)
  - If within policy: initiate refund, status=refund_pending
  - If outside policy: partial/no refund per café policy
  - Write BookingEvent
  - Release slot lock
  - Check waitlist for this slot (handled in Prompt 15)
```

---

### Prompt 10 — Razorpay Webhook Handler
**Model: Opus | Est. time: 4 hours**

```
[PASTE HANDOFF.md HERE]

Build the Razorpay webhook handler. This must be bulletproof.

POST /payments/webhook (no auth — verified by signature)

Security:
  - Verify X-Razorpay-Signature header using HMAC-SHA256
  - Key: RAZORPAY_WEBHOOK_SECRET
  - Body must be raw bytes for signature verification
  - Reject immediately if signature invalid (401)

Idempotency (before any processing):
  - Extract razorpay_event_id from payload
  - Check webhook_logs table: if exists and processed=True, return 200 immediately (already done)
  - Insert webhook_logs row with processed=False (reserve the event)
  - If insert fails (duplicate key), return 200 (race condition between retries — safe)

Event handlers:

payment.captured:
  1. Find payment by razorpay_order_id
  2. Check current booking status — if already "confirmed", skip (return 200)
  3. If booking status is "cancelled" or "expired":
     - Payment succeeded but booking is dead
     - Initiate immediate full refund via Razorpay Refund API
     - Update payment.status = "refund_initiated"
     - Write BookingEvent: {to: "refunded", metadata: {reason: "booking_expired_before_capture"}}
     - Return 200
  4. Normal path:
     - Update payment: status=captured, razorpay_payment_id, payment_method, webhook_received_at
     - Detect if UPI: if payment_method == "upi", call extend_lock_for_upi()
     - Update booking: status=confirmed
     - Update slot: status=booked
     - Write BookingEvent
     - Invalidate slot Redis cache
     - Send confirmation SMS (async, don't await — non-blocking)
     - Mark webhook_log.processed=True

payment.failed:
  1. Find payment by razorpay_order_id
  2. Check event ordering: if booking is already "confirmed", DO NOT process
     (payment.failed arrived after payment.captured — ordering inversion)
     - Log warning, mark webhook processed, return 200
  3. Normal path:
     - Update payment: status=failed
     - Update booking: status=expired
     - Release slot lock (both Redis and DB)
     - Write BookingEvent
     - Invalidate slot cache
     - Send SMS: "Payment failed, slot released. Try again."
     - Mark webhook processed

refund.processed:
  - Update payment.razorpay_refund_id, status=refund_processed
  - Update booking.status = "refunded"
  - Write BookingEvent

refund.failed:
  - Update payment.status = "refund_failed"
  - Write BookingEvent with metadata: {razorpay_refund_id}
  - Flag for manual review (set a Redis key: "refund_failed:{booking_id}")
  - Admin can query these via superadmin endpoint

All handlers wrapped in try/except:
  - If any handler throws: mark webhook_log.error = str(exception), processed=False
  - Return 200 anyway (Razorpay will retry)
  - Failed webhooks are detectable via webhook_logs query
```

---

### Prompt 11 — Pending Booking Expiry Worker
**Model: Opus | Est. time: 2 hours**

```
[PASTE HANDOFF.md HERE]

Build the pending booking expiry worker.

app/workers/expiry_worker.py — runs in the worker container alongside slot_gen_worker

Runs every 30 seconds:

async def expire_pending_bookings():
  1. Acquire distributed lock: "expiry_worker_lock" TTL=25s
     (prevents two worker instances from running simultaneously)
  2. Query: SELECT bookings WHERE status='pending' AND expires_at < now() UTC
  3. For each expired booking:
     a. Check if payment was actually captured (payment.status == 'captured')
        - If yes: this is a webhook delay, don't expire yet, extend expires_at by 5 min
        - This handles webhook arriving just after expiry
     b. Check if Razorpay order is still pending (poll Razorpay order status API)
        - If payment is genuinely processing: extend expires_at by 10 min
        - If payment definitively failed: proceed with expiry
     c. Normal expiry:
        - Update booking.status = "expired"
        - Release slot lock (Redis + DB slot.status = "free")
        - Write BookingEvent: triggered_by="system"
        - Invalidate slot cache
        - Check and notify waitlist (fire-and-forget)
  4. Release distributed lock
  5. Log summary: {checked: N, expired: M, extended: K}

Also handle ghost Razorpay orders:
async def cleanup_ghost_orders():
  - Runs every 5 minutes
  - Query: payments WHERE status='created' AND created_at < now()-45min
  - For each: call Razorpay cancel order API
  - These are orders where user opened payment screen and disappeared
```

---

### Prompt 12 — Refund Service + Cancellation
**Model: Opus | Est. time: 2 hours**

```
[PASTE HANDOFF.md HERE]

Build the complete refund service.

app/services/refund.py:

async def initiate_refund(booking_id, reason, amount_paise=None):
  - amount_paise=None means full refund
  - Calculate refund amount based on cancellation policy if partial
  - Call Razorpay Refunds API:
    POST https://api.razorpay.com/v1/payments/{payment_id}/refund
    {amount: refund_amount_paise, notes: {reason, booking_id}}
  - On API success:
    * Update payment.status = "refund_initiated", razorpay_refund_id
    * Update booking.status = "refund_pending"
    * Write BookingEvent
  - On API failure:
    * Update payment.status = "refund_failed"
    * Set Redis flag: "manual_refund_needed:{booking_id}"
    * Write BookingEvent with error metadata
    * Do NOT update booking to "refunded" — wait for webhook

async def calculate_refund_amount(booking, cafe) → int (paise):
  - time_until_slot = slot.start_time - now()
  - policy = cafe.cancellation_policy
  - If time_until_slot > policy.allowed_before_minutes: full refund
  - Else: slot.price_paise - policy.penalty_paise (min 0)

Admin partial refund for PC failure:
POST /admin/bookings/{booking_id}/partial-refund
  Body: {minutes_completed: int, reason: str}
  - Calculate: refund = total_price * (1 - minutes_completed/total_minutes)
  - Call initiate_refund with calculated amount
  - Update booking.status = "refund_pending"
  - Write BookingEvent with metadata

Superadmin endpoints:
GET /superadmin/refunds/failed — list all failed refunds needing manual action
POST /superadmin/refunds/{booking_id}/mark-resolved — manual resolution
```

---

### Prompt 13 — Edge Cases + Booking Limits
**Model: Opus | Est. time: 2 hours**

```
[PASTE HANDOFF.md HERE]

Add all edge case handling to the booking system.

1. Double-tap protection (backend):
   - Add Redis key: "booking_in_progress:{user_id}" TTL=30s SET NX
   - Set at start of POST /bookings/create
   - Delete on success or failure
   - If SET NX fails: return 429 {error: "Booking already in progress"}

2. Daily booking cap:
   - Query confirmed+pending bookings for user today
   - Config per café (cafe.max_bookings_per_user_per_day, default 3)
   - Global cap: 5 per user per day across all cafés

3. Admin conflict check for extensions:
   - When admin requests extension by N minutes:
   - Query: any "booked"/"locked" slot on same PC starting at current_end_time
   - If conflict: return {can_extend: false, next_free_at: datetime}
   - If clear: extend slot.end_time, update booking, write BookingEvent

4. Version conflict (optimistic locking) on booking updates:
   - All UPDATE queries on bookings must include WHERE version=current_version
   - Increment version on each update
   - If rowcount=0: raise 409 Conflict

5. Walk-in booking (admin creates booking for cash customer):
   POST /admin/bookings/walk-in
   Body: {pc_id, date, start_time, end_time, customer_name}
   - No user account required — store customer_name in metadata
   - Skip payment flow
   - booking.is_walk_in=True, status=confirmed directly
   - Admin must specify payment received (cash)
   - Write BookingEvent: triggered_by=admin

6. GST invoice generation:
   GET /bookings/{booking_id}/invoice
   - Generate PDF invoice with:
     * Booking details, slot times, café name
     * Amount breakdown: base + GST (18%)
     * If user has GST number: B2B invoice format
     * Unique invoice number: INV-{year}-{sequential}
   - Use reportlab or weasyprint for PDF
   - Store URL in booking metadata

7. Superadmin dispute tools:
   GET /superadmin/bookings/{booking_id}/timeline
   - Returns full BookingEvent log with timestamps
   - This is how you investigate every dispute
```

---

## 👮 PHASE 4 — ADMIN PANEL (Days 12–14)

### Prompt 14 — Admin Panel Scaffold
**Model: Sonnet | Est. time: 2 hours**

```
[PASTE HANDOFF.md HERE]

Bootstrap the Next.js admin panel.

npx create-next-app@latest admin-panel --typescript --tailwind --app

Install: shadcn/ui, lucide-react, react-query, axios, date-fns, react-webcam (for QR scanner)

Setup:
1. Auth: JWT stored in httpOnly cookie, refresh on 401
2. API client (axios instance) with base URL from env, auto-attach JWT header
3. Layout: sidebar with nav items:
   - Today's Slots (default)
   - QR Check-in
   - My Café Settings
   - Payouts
   - Walk-in Booking
4. Sidebar shows café name + admin name at top
5. Mobile-responsive (tablet is primary device for café admins)
6. Dark theme by default (gaming café aesthetic)
7. Color system:
   - Free slots: green (#22c55e)
   - Booked: red (#ef4444)
   - Pending/Locked: amber (#f59e0b)
   - Blocked: gray (#6b7280)
```

---

### Prompt 15 — Slot Grid Dashboard
**Model: Sonnet | Est. time: 2 hours**

```
[PASTE HANDOFF.md HERE]

Build the main admin dashboard — today's slot grid.

Page: /dashboard (default after login)

Requirements:
1. Date picker at top (default: today IST)
2. Grid: rows = PCs, columns = time slots (30/60 min blocks)
3. Each cell: colored by status, shows customer name if booked
4. Real-time refresh every 30 seconds via polling (react-query refetchInterval)
5. Click any cell → slide-out panel with:
   - Slot details
   - If booked: customer name, phone (last 4 masked), booking_id
   - Actions based on status:
     * Free: "Create Walk-in"
     * Pending: "Force Expire", view timer countdown
     * Booked/Confirmed: "Mark Arrived", "Mark No-show", "Cancel Booking", "Extend"
     * Arrived: "Mark Completed", "Report PC Failure" (triggers partial refund flow)
6. Extend action: shows available minutes + conflict warning if applicable
7. No-show: requires confirmation dialog "User has X no-shows total. Proceed?"
8. Stats bar at top:
   - Total slots today / Booked / Available / Revenue collected
9. Current occupancy badge (live from Redis counter)
```

---

### Prompt 16 — QR Scanner Check-in
**Model: Sonnet | Est. time: 1.5 hours**

```
[PASTE HANDOFF.md HERE]

Build the QR check-in screen.

Page: /checkin

Requirements:
1. Full-screen camera view using react-webcam + jsQR (decode QR)
2. Scan QR code from customer's phone
3. On scan: POST /admin/bookings/checkin {qr_token: string}
4. Backend validates:
   - Extract booking_id from QR token
   - Verify HMAC: HMAC-SHA256(booking_id + str(floor(now/300)), booking.qr_base_secret)
   - Accept tokens from current and previous 5-minute window (10 min total validity)
   - Booking must be confirmed status
   - Slot date must be today
   - Return booking details + success/failure
5. Success UI: big green checkmark, customer name, PC assignment, slot time
6. Failure states:
   - "Invalid QR" (tampered/wrong)
   - "QR Expired" (screenshot from yesterday — TOTP validation failed)
   - "Already Checked In" (scanned twice)
   - "Wrong Café" (QR from different café)
7. After successful scan: automatically mark booking as arrived
8. Update occupancy counter in Redis (+1)
9. Auto-reset camera after 3 seconds for next scan

Also build the check-in endpoint:
POST /admin/bookings/checkin
  - Validate admin owns the café the booking is for
  - TOTP validation of QR token
  - Update booking.arrived_at, status stays "confirmed" (completed at end)
  - Increment Redis occupancy counter
  - Write BookingEvent
```

---

### Prompt 17 — Payout Ledger + Café Settings
**Model: Sonnet | Est. time: 2 hours**

```
[PASTE HANDOFF.md HERE]

Build payout ledger screen and café settings.

Payout screen (/payouts):
1. Weekly summary: total bookings, gross revenue, platform fee (₹2/booking for now), net
2. Table: each confirmed booking this week
3. "Request Payout" button → creates payout record with status=pending
4. Status badges: pending/processing/paid
5. API: GET /admin/payouts — returns ledger for this admin's café

Backend payout endpoints:
GET /admin/payouts?period=week|month
  - Calculate gross from confirmed bookings in period
  - Subtract walk-in bookings (cash, already with admin)
  - Show payout history

POST /admin/payouts/request
  - Create Payout record for current period
  - Superadmin sees all pending payout requests

GET /superadmin/payouts/pending — all cafés with pending payouts
POST /superadmin/payouts/{id}/mark-paid {reference: str}

Café settings screen (/settings):
1. Update café details (name, address, images)
2. Update operating hours → triggers slot regeneration for next 7 days
3. PC management: add, edit label/type, toggle active
4. No-show policy config
5. Cancellation policy config
6. Special hours: calendar picker, set closed or custom hours
7. All updates call their respective admin endpoints
```

---

## 📱 PHASE 5 — CUSTOMER WEB APP (Days 15–18)

### Prompt 18 — Customer App Scaffold + OTP Login
**Model: Sonnet | Est. time: 2 hours**

```
[PASTE HANDOFF.md HERE]

Bootstrap the customer Next.js PWA.

npx create-next-app@latest customer-app --typescript --tailwind --app

Install: shadcn/ui, lucide-react, react-query, axios, framer-motion, next-pwa

PWA setup:
- next-pwa config in next.config.js
- manifest.json: name="CaféBook", theme_color="#111", display=standalone
- Service worker for offline shell
- Add to homescreen prompt

Design direction (IMPORTANT for Antigravity):
- Dark theme, gaming aesthetic
- Accent color: electric blue #3b82f6
- Font: Space Grotesk (headings), Inter (body)
- Glassy cards with subtle border (#ffffff10)
- NOT generic — feels like a gaming product

Auth flow:
1. /login page
   - Phone input with +91 prefix
   - Profile selector (Me / Family — for shared phone)
   - "Get OTP" button
2. /verify page
   - 6-digit OTP input (auto-advance between digits)
   - Resend OTP countdown (60 seconds)
   - On success: redirect to /home
3. JWT stored in memory + refresh token in httpOnly cookie
4. Auto-refresh on 401 using axios interceptor
5. Protected route wrapper component
```

---

### Prompt 19 — Café Discovery + Slot Grid
**Model: Sonnet | Est. time: 3 hours**

```
[PASTE HANDOFF.md HERE]

Build café discovery and slot selection.

/home page:
1. "Near me" tab (uses browser geolocation, calls GET /cafes?lat=&lng=)
2. "Search" tab (city/area text search)
3. Café cards: image, name, rating, distance, price range, "X PCs available now"
4. Loading skeleton while fetching

/cafes/[id] page:
1. Hero image(s) with swipe carousel
2. Café info: specs, hours, address, distance
3. Date selector (today + next 7 days, disable past)
4. PC type filter tabs (All / Standard / High-End / VIP)
5. Slot grid:
   - Columns: PCs
   - Rows: time slots
   - Color coded: green=free, red=booked, amber=pending, gray=past/blocked
   - Tap free slot → booking flow
6. Current occupancy indicator: "🟢 12/20 PCs in use — popular right now"
7. Polling: refresh slot grid every 30 seconds
8. If generation status is "loading": show skeleton with "Slots loading..." message
9. Price shown on each free slot cell
```

---

### Prompt 20 — Booking Flow + Razorpay Checkout
**Model: Opus | Est. time: 4 hours**

```
[PASTE HANDOFF.md HERE]

Build the customer booking and payment flow.

Slot selection → Payment sheet → Confirmation

Step 1 — Booking confirmation sheet (bottom drawer):
- Shows: PC label, time, date, price breakdown (base + 18% GST)
- Cancellation policy notice (must show before payment)
- "Confirm & Pay" button
- If user is banned: show ban reason + ban_until

Step 2 — Create booking:
- POST /bookings/create {slot_id}
- Disable button immediately on tap (double-tap protection)
- Show loading state
- On 409: "Slot just got taken! Going back..." with slot refresh

Step 3 — Razorpay checkout:
- Load Razorpay JS SDK
- Open Razorpay modal with:
  * order_id from API response
  * prefill: {contact: user.phone}
  * theme: {color: "#3b82f6"}
- Show countdown timer: "Slot reserved for X:XX" (from expires_at)
- If timer hits 0: show "Reservation expired" and dismiss checkout

Step 4 — Payment result handling:
- On Razorpay success callback: do NOT trust it — show "Confirming payment..."
- Poll GET /bookings/{booking_id} every 3 seconds until status = "confirmed" or "expired"
- Timeout after 5 minutes (UPI can be slow)
- On confirmed: navigate to /bookings/{booking_id}/success
- On expired: navigate to /home with "Payment failed" toast

Step 5 — Success page /bookings/[id]/success:
- QR code displayed (large, easy to screenshot)
- Booking details
- "Add to Calendar" button (ICS download)
- "Download Invoice" button
- Share button (WhatsApp deep link with booking summary text)
- "View all bookings" link

Countdown timer UX:
- Amber warning at 30 seconds
- Red pulsing at 10 seconds
- On expire: auto-close Razorpay modal, show "Too slow! Slot released." toast
```

---

### Prompt 21 — My Bookings + Notifications
**Model: Sonnet | Est. time: 2 hours**

```
[PASTE HANDOFF.md HERE]

Build My Bookings screen and notification triggers.

/bookings page:
Tabs: Upcoming | Past | Cancelled

Each booking card shows:
- Café name, PC label, date/time
- Status badge
- QR code preview (tap to expand full screen)
- Cancel button (if allowed by policy + time remaining)
- Download invoice button
- If no_show: show warning "No-show #X — Y more will result in 7-day ban"

Cancel flow:
- Shows refund amount before confirming (based on policy)
- Confirmation dialog
- POST /bookings/{id}/cancel
- Optimistic update + refetch

Notification triggers (backend — app/services/notification.py):

async def send_sms(phone: str, message: str, template_id: str):
  - Use Fast2SMS transactional route
  - Include template_id for DLT compliance (mandatory in India)
  - Log success/failure but never block main flow (fire and forget)

Trigger points:
1. Booking confirmed (from webhook handler):
   SMS: "Booked! {café_name}, PC {label}, {date} {time}. QR: {short_link}"

2. 15 minutes before slot (APScheduler job every 5 min):
   - Query: confirmed bookings where start_time IST is 10-20 min from now
   - SMS: "Your slot at {café_name} starts in 15 min. Show QR at entry."

3. Booking cancelled:
   SMS: "Booking cancelled. Refund of ₹{amount} will reflect in 5-7 days."

4. No-show marked:
   SMS: "No-show recorded. {X} more will result in a 7-day booking ban."

5. Waitlist slot available:
   SMS: "A slot opened at {café_name} {time}! Book within 10 min: {link}"

DLT compliance:
  - Every SMS template must be registered on DLT portal
  - Include PE ID and Template ID in Fast2SMS API call
  - Store template_ids in config.py
```

---

## 🛡️ PHASE 6 — ADVANCED FEATURES (Days 19–21)

### Prompt 22 — No-Show Strike System
**Model: Sonnet | Est. time: 1.5 hours**

```
[PASTE HANDOFF.md HERE]

Build the no-show management system.

When admin marks a booking as no_show:

Backend flow:
1. POST /admin/bookings/{id}/no-show
2. Check grace period: if now < slot.start_time + cafe.no_show_policy.grace_minutes → reject
   (Too early to mark as no-show)
3. Update booking.status = "no_show"
4. Increment user.no_show_count
5. Update user.trust_score = max(0, trust_score - 0.2)
6. Write BookingEvent
7. Release slot (mark as free — it's now reusable)
8. Update occupancy counter (-1 if they were marked arrived)
9. Check strike threshold:
   - no_show_count >= 3:
     * Set user.is_banned = True
     * Set user.ban_until = now + 7 days
     * SMS: "Booking access suspended for 7 days due to repeated no-shows."
   - no_show_count == 1 or 2:
     * SMS warning with count
10. Apply penalty if cafe.no_show_policy.penalty_paise > 0:
    - Issue partial refund: (total - penalty)
    - If penalty >= total: no refund

Admin sees on no-show button:
- "This user has X no-shows (trust score: Y)"
- Warning if this will trigger a ban

Recovery: User can contact support via superadmin panel to appeal a strike
POST /superadmin/users/{id}/remove-strike {reason: str}
```

---

### Prompt 23 — Waitlist System
**Model: Sonnet | Est. time: 2 hours**

```
[PASTE HANDOFF.md HERE]

Build the slot waitlist feature.

Customer-facing:
- When slot is booked/locked: show "Join Waitlist" button
- POST /slots/{slot_id}/waitlist → creates Waitlist record
- Max 5 people per slot on waitlist
- User can join waitlist for max 3 slots at a time
- GET /bookings shows waitlist entries under new "Waitlisted" tab

Waitlist processing (triggered on slot release):
app/services/waitlist.py:
async def process_waitlist_for_slot(slot_id, redis):
  1. Query: first unnotified waitlist entry for this slot (ordered by created_at)
  2. If none: return
  3. Check: user is not banned, user hasn't hit daily limit
  4. Set waitlist.notified = True, notified_at = now()
  5. Set waitlist.expires_at = now + 10 minutes
  6. Reserve slot for this user via Redis:
     key="waitlist_hold:{slot_id}" value=user_id TTL=600s
  7. Send SMS: notification type 5 from Prompt 21
  8. If user doesn't book within 10 min:
     - Expiry worker detects: waitlist_hold key gone + slot still free
     - Move to next waitlist entry (process next person)

When is waitlist triggered:
  - Booking expires (expiry worker)
  - Booking cancelled (cancel endpoint)
  - Admin cancels a booking
  - Emergency café closure (bulk cancel)

API endpoints:
POST /slots/{slot_id}/waitlist — join
DELETE /slots/{slot_id}/waitlist — leave
GET /bookings/waitlisted — user's waitlist entries
```

---

### Prompt 24 — Emergency Closure + Bulk Operations
**Model: Sonnet | Est. time: 1.5 hours**

```
[PASTE HANDOFF.md HERE]

Build emergency closure and bulk operations.

POST /admin/cafes/{cafe_id}/emergency-close
Body: {from_datetime: datetime, reason: str}
- Requires cafe_admin auth + ownership check
- Query: all bookings for this café where slot.start_time > from_datetime
         and status in ['pending', 'confirmed']
- For each booking (process in batches of 50):
  1. Update booking.status = "cancelled"
  2. Initiate full refund
  3. Release slot lock
  4. Send SMS to each customer
  5. Write BookingEvent: triggered_by="admin", metadata={reason}
- Update café: is_active = False
- Clear slot cache for this café
- Return: {cancelled_count: N, refunds_initiated: M, errors: []}

POST /admin/cafes/{cafe_id}/reopen
- Set is_active = True
- Trigger slot regeneration for today + next 7 days

Bulk slot operations for superadmin:
POST /superadmin/cafes/{cafe_id}/block-slots
Body: {pc_ids: list, date: date, reason: str}
- Set specified slots to status="blocked"
- Any pending/confirmed bookings → cancel + refund
- Use case: maintenance, tournaments

GET /superadmin/dashboard
- Total bookings today across all cafés
- Revenue today
- Active users
- Failed refunds count (action needed)
- No-show rate per café
- Redis + DB health status
```

---

### Prompt 25 — Dynamic Last-Minute Pricing
**Model: Sonnet | Est. time: 1.5 hours**

```
[PASTE HANDOFF.md HERE]

Build last-minute dynamic pricing.

APScheduler job: runs every 5 minutes

async def apply_last_minute_pricing():
  1. Query: free slots where start_time is 20-40 min from now IST
  2. For each: if not already discounted:
     - new_price = original_price * 0.70 (30% off, configurable per café)
     - Update slot.price_paise = new_price
     - Set slot metadata: {discounted: true, original_price: X, discount_reason: "last_minute"}
  3. Invalidate slot cache for affected cafés

Customer-facing:
  - Discounted slots show: ~~₹120~~ ₹84 with "Last minute deal!" badge
  - Filter button: "Show deals only"

Opt-out for cafés:
  - Café setting: enable_dynamic_pricing (bool, default True)
  - Discount percentage: configurable (default 30%)
  - Minimum time before slot: configurable (default 30 min)
```

---

## 🚀 PHASE 7 — HARDENING & DEPLOYMENT (Days 22)

### Prompt 26 — Security Hardening
**Model: Sonnet | Est. time: 2 hours**

```
[PASTE HANDOFF.md HERE]

Harden the entire API for production.

1. Rate limiting (verify all these are in place):
   - OTP send: 3 per phone per 10 min
   - OTP verify: 3 attempts per OTP
   - Booking create: 10 per user per minute
   - General API: 100 per IP per minute
   - Webhook: no rate limit (Razorpay IPs only — whitelist)

2. Razorpay webhook IP whitelist:
   - Only accept webhook POST from Razorpay IP ranges
   - https://razorpay.com/docs/webhooks/validate-test/
   - Middleware that checks X-Forwarded-For against whitelist

3. Input validation:
   - All UUIDs validated (invalid UUID → 400, not 500)
   - All dates: reject past dates for booking creation
   - Phone: exactly 10 digits, starts with 6-9, Indian numbers only
   - Monetary amounts: never accept from client — always calculate server-side

4. SQL injection: using SQLAlchemy ORM everywhere (parameterized — already safe)

5. Secrets audit:
   - No secrets in code or logs
   - Razorpay keys only in .env
   - Log sanitizer: strip phone numbers from logs (replace with ***XXXX)

6. CORS: in production, whitelist only your domain

7. Dependency check: pip-audit for known vulnerabilities

8. Health check improvements:
   GET /health returns:
   {
     db: "ok" | "error",
     redis: "ok" | "error",
     worker: "ok" | "error",  ← check Redis key set by worker heartbeat
     razorpay: "ok" | "error"  ← lightweight API ping
   }
```

---

### Prompt 27 — Race Condition + Load Testing
**Model: Sonnet | Est. time: 2 hours**

```
[PASTE HANDOFF.md HERE]

Write and run concurrency tests.

tests/test_race_conditions.py using pytest-asyncio:

Test 1 — Double booking attempt:
  - Create 1 free slot
  - Spawn 50 concurrent coroutines all calling POST /bookings/create for same slot
  - Assert: exactly 1 booking created, 49 get 409
  - Assert: slot.status = "locked" (not "free" or corrupted)

Test 2 — Webhook ordering inversion:
  - Create confirmed booking
  - Fire payment.failed webhook
  - Assert: booking remains confirmed (not expired)
  - Assert: BookingEvent log shows the skip was recorded

Test 3 — Expiry worker + webhook race:
  - Create pending booking with expires_at = now + 2 seconds
  - Simultaneously: wait 3 seconds (expiry runs) + fire payment.captured webhook
  - Assert: one of them wins cleanly, no inconsistent state
  - Acceptable outcomes: either refund initiated OR booking confirmed (not both)

Test 4 — Slot cache consistency:
  - Book a slot
  - Immediately query GET /cafes/{id}/slots
  - Assert: slot shows as "booked" not "free" (cache invalidated)

Test 5 — Redis down behavior:
  - Temporarily set Redis URL to invalid
  - Call POST /bookings/create
  - Assert: 503 returned, no DB records created, slot status unchanged

Run with: pytest tests/test_race_conditions.py -v --asyncio-mode=auto
All 5 tests must pass before deployment.
```

---

### Prompt 28 — Production Docker Compose
**Model: Flash | Est. time: 1 hour**

```
[PASTE HANDOFF.md HERE]

Create production-ready Docker Compose configuration.

docker-compose.prod.yml:

services:
  api:
    build: ./backend
    command: uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4
    env_file: .env.prod
    depends_on: [postgres, redis]
    restart: always
    healthcheck: curl /health

  worker:
    build: ./backend
    command: python -m app.workers.scheduler  ← SEPARATE from api
    env_file: .env.prod
    depends_on: [postgres, redis]
    restart: always

  postgres:
    image: postgres:16-alpine
    volumes: [pgdata:/var/lib/postgresql/data]
    env_file: .env.prod
    restart: always

  redis:
    image: redis:7-alpine
    command: redis-server --requirepass ${REDIS_PASSWORD} --appendonly yes
    volumes: [redisdata:/data]
    restart: always

  admin-panel:
    build: ./admin-panel
    environment: [NEXT_PUBLIC_API_URL]
    restart: always

  customer-app:
    build: ./customer-app
    environment: [NEXT_PUBLIC_API_URL]
    restart: always

  nginx:
    image: nginx:alpine
    ports: ["80:80", "443:443"]
    volumes: [./nginx.conf:/etc/nginx/nginx.conf, ./ssl:/etc/ssl]
    depends_on: [api, admin-panel, customer-app]
    restart: always

nginx.conf routing:
  api.yourdomain.com → api:8000
  admin.yourdomain.com → admin-panel:3000
  app.yourdomain.com → customer-app:3001

Also create:
- Alembic upgrade head command in api startup script
- Redis persistence (AOF mode)
- Postgres daily backup script (pg_dump to S3)
- Worker heartbeat: worker sets Redis key "worker_heartbeat" every 60s
  API /health checks this key — alerts if missing
```

---

## 📋 HANDOFF.md TEMPLATE
> Keep this file updated after every single Antigravity session

```markdown
# HANDOFF.md — Gaming Café Booking Platform

## Last Updated
{date and time}

## Current Phase
Phase X — {phase name}

## Last Completed Prompt
Prompt #{N} — {prompt name} ✅

## Next Prompt
Prompt #{N+1} — {prompt name}

## Current Stack Versions
- FastAPI: {version}
- SQLAlchemy: {version}
- Alembic: {current revision}
- Next.js: {version}

## Database State
- Last migration: {migration name}
- Tables confirmed in DB: {list}
- Any schema changes from plan: {note or "none"}

## Environment
- API running on: localhost:8000
- Admin panel: localhost:3000
- Customer app: localhost:3001
- Postgres: localhost:5432
- Redis: localhost:6379

## Known Issues / Bugs
- {issue 1}
- {issue 2}

## Completed Features
- [ ] Prompt 1 — Scaffold
- [ ] Prompt 2 — Schema
...

## Critical Notes
- {anything that broke and how it was fixed}
- {any deviation from the original plan}
- {env vars that need to be set}

## Test Results
- Race condition tests: {pass/fail/not run}
- Manual payment test: {pass/fail/not run}
- Webhook test: {pass/fail/not run}
```

---

## ⚡ PRE-LAUNCH CHECKLIST

### Before First Real Payment
- [ ] Razorpay business KYC complete (settlement cap lifted)
- [ ] All webhook events configured in Razorpay dashboard
- [ ] Webhook secret set and verified
- [ ] Test payment with ₹1 amount in Razorpay test mode
- [ ] Test payment in live mode with real card
- [ ] Test UPI payment specifically (different flow)
- [ ] Refund tested end-to-end
- [ ] All SMS templates registered on DLT portal
- [ ] Fast2SMS transactional route verified (not promotional)
- [ ] GST invoice generated and verified

### Before First Café Onboarded
- [ ] Race condition tests all pass
- [ ] Expiry worker confirmed running (check /health)
- [ ] Slot generation cron confirmed running
- [ ] Redis persistence enabled
- [ ] Daily DB backup configured
- [ ] No-show system tested manually
- [ ] QR check-in tested on real mobile device
- [ ] Emergency close tested with dummy data
- [ ] Privacy policy + Terms of service pages live

### Before Going Public
- [ ] SSL certificate on all domains
- [ ] CORS locked to your domains only
- [ ] Rate limiting verified (use k6 or locust)
- [ ] Log sanitization working (no phone numbers in logs)
- [ ] Error alerting set up (even basic email on 500s)
- [ ] Razorpay settlement cap raised via KYC

---

## 📊 TOTAL EFFORT SUMMARY

| Phase | Days | Prompts | Primary Model |
|---|---|---|---|
| Foundation | 1–3 | 4 | Sonnet/Opus |
| Café + Slot Engine | 4–6 | 4 | Opus |
| Booking Engine | 7–11 | 6 | Opus |
| Admin Panel | 12–14 | 4 | Sonnet |
| Customer App | 15–18 | 4 | Sonnet/Opus |
| Advanced Features | 19–21 | 4 | Sonnet |
| Hardening | 22 | 3 | Sonnet/Flash |
| **TOTAL** | **22 days** | **29 prompts** | |

---

*Built with Antigravity + Claude. Updated: {date}*
```
