#!/bin/bash
# Run this once to create your entire Engineering OS folder structure
# Usage: bash setup_os.sh

mkdir -p learning
mkdir -p decisions
mkdir -p architecture
mkdir -p project_logs/gaming_cafe
mkdir -p project_logs/nexo
mkdir -p linkedin_content
mkdir -p handoff
mkdir -p mistakes
mkdir -p concepts
mkdir -p interview_prep
mkdir -p future_improvements
mkdir -p reflection

echo "Folders created. Creating template files..."

# ─────────────────────────────────────────────────────────
# HANDOFF
# ─────────────────────────────────────────────────────────
cat > handoff/HANDOFF.md << 'EOF'
# HANDOFF.md
**Last updated:** {date}
**Project:** Gaming Café Booking Platform
**Session summary:** {what happened last session}

## Current System State
**What works right now:**
- [ ] Nothing yet — pre-build

**What is broken or incomplete:**
- Everything — we haven't started

**What was NOT done that was planned:**
- N/A

## Architecture as of now
Pre-build. Architecture documented in architecture/current_architecture.md

**Key files:**
- None yet

## Database State
**Migration status:** No migrations run
**Tables that exist:** None
**Pending schema changes:** Full initial schema (see architecture/data_models.md)

## Environment
- API: localhost:8000
- Admin panel: localhost:3000
- Customer app: localhost:3001
- PostgreSQL: localhost:5432
- Redis: localhost:6379

## Next Steps (in order)
1. Prompt 1 — Project scaffold (FastAPI + Docker Compose + Redis + Alembic)
2. Prompt 2 — Full DB schema + initial Alembic migration
3. Prompt 3 — OTP auth system

## Concepts Uzair learned this session
- None yet

## Decisions made this session
- Stack: FastAPI (Python) — chosen over Go for team debugging ease

## Open questions
- Railway vs AWS for initial deployment?
- Razorpay Route vs manual payouts for MVP?

## Warnings for next session
- Use async SQLAlchemy (NOT sync) — critical for FastAPI performance
- APScheduler MUST run in a separate container, not in the API process
- All datetimes stored as UTC, converted to IST at API response layer
EOF

# ─────────────────────────────────────────────────────────
# LEARNING FILES
# ─────────────────────────────────────────────────────────
cat > learning/python_notes.md << 'EOF'
# Python Deep Dive Notes
> Updated automatically by Learning Coach during sessions

---

## How to use this file
Each entry follows: concept → why it exists → mental model → internals → mistakes → project usage → my explanation

---

## Async / Await
**Date learned:**
**Why it exists:** Python is single-threaded. Without async, one slow I/O operation (DB query, HTTP call) blocks the entire program. Async allows the interpreter to work on other things while waiting.
**Mental model:** A waiter who takes your order, goes to the kitchen (starts cooking = I/O), then serves other tables while your food is being prepared. Never stands still waiting.
**How it works:** The event loop is a scheduler. `await` tells it "I'm waiting for I/O, go do something else." The coroutine is paused and resumed when the I/O completes.
**Common mistakes:**
  - Calling a sync blocking function inside async code (blocks the whole event loop)
  - Forgetting `await` keyword (returns a coroutine object, not the result)
  - Using `time.sleep()` instead of `asyncio.sleep()` inside async functions
**Used in our project:** Every FastAPI route, every SQLAlchemy query, every Redis call
**My explanation (Uzair's words):** {fill after teaching session}

---

## Generators and Iterators
**Date learned:**
**Why it exists:**
**Mental model:**
**How it works:**
**Common mistakes:**
**Used in our project:**
**My explanation:**

---

## Type Hints and Pydantic
**Date learned:**
**Why it exists:**
**Mental model:**
**How it works:**
**Common mistakes:**
**Used in our project:**
**My explanation:**

---

## Decorators
**Date learned:**
**Why it exists:**
**Mental model:**
**How it works:**
**Common mistakes:**
**Used in our project:**
**My explanation:**

---

## Context Managers (with statement)
**Date learned:**
**Why it exists:**
**Mental model:**
**How it works:**
**Common mistakes:**
**Used in our project:**
**My explanation:**

EOF

cat > learning/fastapi_notes.md << 'EOF'
# FastAPI Deep Dive Notes
> Updated automatically by Learning Coach during sessions

---

## Dependency Injection
**Date learned:**
**Why it exists:** To share resources (DB sessions, Redis connections, current user) across routes without global state or repetitive code.
**Mental model:** FastAPI automatically creates and passes "dependencies" to route functions. You declare what you need, FastAPI figures out how to provide it.
**How it works:** FastAPI inspects function signatures. Anything typed as `Depends(something)` gets resolved before your function runs. Depends can depend on other Depends — it's a DAG.
**Common mistakes:**
  - Creating a DB session per request without closing it (use async generator pattern)
  - Making dependencies that do too much (keep them focused)
  - Not handling async dependencies properly
**Used in our project:** `get_db()`, `get_redis()`, `get_current_user()`, `require_cafe_admin()`
**My explanation:**

---

## Request Lifecycle
**Date learned:**
**Why it exists:**
**Mental model:**
**How it works:**
**Common mistakes:**
**Used in our project:**
**My explanation:**

---

## Background Tasks
**Date learned:**
**Why it exists:**
**Mental model:**
**How it works:**
**Common mistakes:**
**Used in our project:**
**My explanation:**

---

## Pydantic Models vs SQLAlchemy Models
**Date learned:**
**Why it exists:** Two different jobs. SQLAlchemy models describe the database. Pydantic models describe the API interface. They should NOT be the same thing.
**Mental model:** SQLAlchemy = blueprint of storage. Pydantic = contract with the client. Conflating them means your DB structure leaks into your API or vice versa.
**How it works:** You create SQLAlchemy models for the ORM, Pydantic schemas for request/response. Map between them manually or with orm_mode.
**Common mistakes:**
  - Using SQLAlchemy models as response models (exposes internal fields)
  - Forgetting `from_orm=True` / `model_validate` when converting
**Used in our project:** Every endpoint has separate schema classes
**My explanation:**

---

## Middleware
**Date learned:**
**Why it exists:**
**Mental model:**
**How it works:**
**Common mistakes:**
**Used in our project:**
**My explanation:**

---

## Exception Handling
**Date learned:**
**Why it exists:**
**Mental model:**
**How it works:**
**Common mistakes:**
**Used in our project:**
**My explanation:**

EOF

cat > learning/postgresql_notes.md << 'EOF'
# PostgreSQL Deep Dive Notes
> Updated automatically by Learning Coach during sessions

---

## ACID Transactions
**Date learned:**
**Why it exists:** Multiple operations that must all succeed or all fail. Without transactions, a crash between two related writes leaves your data in an inconsistent state.
**Mental model:** A transaction is a promise: "all of this happens, or none of it does." Atomicity = all or nothing. Consistency = rules are never violated. Isolation = transactions don't see each other's in-progress work. Durability = committed data survives crashes.
**How it works:** PostgreSQL uses WAL (Write-Ahead Log). Changes are written to the log first, then to the actual tables. If the system crashes, the log is replayed to restore state.
**Common mistakes:**
  - Multi-table writes outside a transaction (e.g., creating booking + payment separately = inconsistency on crash)
  - Long-running transactions that hold locks
  - Not rolling back on exception in async code
**Used in our project:** Booking creation (lock slot + create booking + create payment = one transaction)
**My explanation:**

---

## Indexes — How They Actually Work
**Date learned:**
**Why it exists:** Full table scans on large tables are slow. An index is a separate data structure that lets PostgreSQL find rows without reading every row.
**Mental model:** A book's index. Without it, you read every page to find "Redis." With it, you go to the index, find "Redis → page 247", and jump straight there.
**How it works:** B-Tree index (default) stores keys in sorted order. Lookup is O(log n) instead of O(n). Writes are slower because the index must also be updated.
**Common mistakes:**
  - Indexing every column "just in case" (slows writes, wastes space)
  - Not indexing foreign keys (join performance)
  - Index on (a, b) doesn't help queries on just (b)
**Used in our project:** slots(cafe_id, date, status), bookings(user_id, status), webhook_logs(razorpay_event_id)
**My explanation:**

---

## Connection Pooling
**Date learned:**
**Why it exists:**
**Mental model:**
**How it works:**
**Common mistakes:**
**Used in our project:**
**My explanation:**

---

## Optimistic vs Pessimistic Locking
**Date learned:**
**Why it exists:**
**Mental model:**
**How it works:**
**Common mistakes:**
**Used in our project:** Optimistic locking on bookings table via `version` column
**My explanation:**

---

## EXPLAIN ANALYZE
**Date learned:**
**Why it exists:**
**Mental model:**
**How it works:**
**Common mistakes:**
**Used in our project:**
**My explanation:**

---

## Alembic Migrations
**Date learned:**
**Why it exists:** Your database schema will change. Without migrations, you're manually editing live database tables. Migrations are version-controlled, reversible schema changes.
**Mental model:** Git for your database schema. Each migration is a commit. You can go forward (upgrade) or backward (downgrade).
**How it works:** Alembic compares your SQLAlchemy models against the current DB state and generates migration scripts. You review, then run them.
**Common mistakes:**
  - Auto-generating without reviewing (can generate incorrect or destructive migrations)
  - Not running migrations in the correct order
  - Making manual DB changes that diverge from Alembic's history
**Used in our project:** All schema changes go through Alembic — never manual SQL
**My explanation:**

EOF

cat > learning/architecture_notes.md << 'EOF'
# Software Architecture Notes
> Updated automatically by Learning Coach during sessions

---

## Separation of Concerns
**Date learned:**
**Why it exists:** Code that does everything in one place is hard to test, hard to change, and hard to understand. Separating concerns means each part of the code has one job.
**Mental model:** A restaurant kitchen. Chef cooks. Waiter serves. Cashier handles money. Nobody does all three. When something goes wrong, you know exactly who to fix.
**How it works:** In our backend: Routes handle HTTP concerns only. Services handle business logic. Models handle data structure. This means you can change how payment works without touching the HTTP layer.
**Common mistakes:**
  - Business logic inside route handlers (hard to test, hard to reuse)
  - Database queries directly in route handlers (couples HTTP to storage)
  - Giant "utils.py" files that become a dumping ground
**Used in our project:** app/api/routes/ → app/services/ → app/models/ layering
**My explanation:**

---

## Idempotency
**Date learned:**
**Why it exists:** Networks are unreliable. Requests can be sent twice. An idempotent operation can be applied multiple times and produces the same result. Critical for payments and webhooks.
**Mental model:** Pressing an elevator button twice doesn't call two elevators. The second press is idempotent.
**How it works:** Idempotency keys — a unique identifier per operation. Before processing, check if you've seen this key before. If yes, return the previous result. If no, process and store the key.
**Common mistakes:**
  - Assuming webhook events arrive exactly once (they don't)
  - Not having a unique constraint backing the idempotency check
  - Checking idempotency after side effects instead of before
**Used in our project:** Razorpay webhook processing uses razorpay_event_id as idempotency key
**My explanation:**

---

## Event-Driven Architecture
**Date learned:**
**Why it exists:**
**Mental model:**
**How it works:**
**Common mistakes:**
**Used in our project:**
**My explanation:**

---

## Caching Strategies
**Date learned:**
**Why it exists:**
**Mental model:**
**How it works:**
**Common mistakes:**
**Used in our project:** Redis slot grid cache per café per day, 60-second TTL
**My explanation:**

---

## Background Workers vs API Processes
**Date learned:**
**Why it exists:**
**Mental model:**
**How it works:**
**Common mistakes:**
**Used in our project:** Worker container separate from API — APScheduler safety
**My explanation:**

EOF

cat > learning/system_design.md << 'EOF'
# System Design Notes
> Updated automatically by Learning Coach during sessions

---

## How to Approach Any System Design Question
1. Clarify requirements (functional + non-functional)
2. Estimate scale (users, requests/sec, data volume)
3. High-level design (components + connections)
4. Deep dive on critical components
5. Address bottlenecks + failure modes

---

## Rate Limiting
**Date learned:**
**Why it exists:**
**Approaches:** Fixed window, sliding window, token bucket, leaky bucket
**Tradeoffs:**
**Used in our project:** Booking endpoint — 10 req/min per user. OTP — 3 req/10min per phone.
**My explanation:**

---

## Distributed Locking
**Date learned:**
**Why it exists:** Multiple processes/servers trying to modify the same resource simultaneously. Need a way to ensure only one succeeds.
**Mental model:** A bathroom key at a gas station. Only one key exists. You must acquire it before entering.
**How it works:** Redis SET NX (Set if Not eXists) is atomic. Only one caller can set a key that doesn't exist — the winner holds the lock. TTL prevents deadlocks if the holder crashes.
**Common mistakes:**
  - Not setting TTL (deadlock if holder crashes)
  - TTL too short (lock expires during slow operation)
  - Not using SET NX atomically (race condition between check and set)
**Used in our project:** Redis slot locking — prevents double booking
**My explanation:**

---

## Database Sharding vs Replication
**Date learned:**
**Why it exists:**
**Mental model:**
**How it works:**
**Common mistakes:**
**My explanation:**

---

## CAP Theorem
**Date learned:**
**Why it exists:**
**Mental model:**
**How it works:**
**My explanation:**

EOF

cat > learning/ai_engineering.md << 'EOF'
# AI Engineering & Agents Notes
> Updated automatically by Learning Coach during sessions

---

## LLM API Fundamentals
**Date learned:**
**Why it exists:**
**Mental model:**
**How it works:**
**Common mistakes:**
**My explanation:**

---

## Prompt Engineering
**Date learned:**
**Why it exists:**
**Mental model:**
**How it works:**
**Common mistakes:**
**My explanation:**

---

## RAG (Retrieval Augmented Generation)
**Date learned:**
**Why it exists:**
**Mental model:**
**How it works:**
**Common mistakes:**
**My explanation:**

---

## Agentic Systems
**Date learned:**
**Why it exists:**
**Mental model:**
**How it works:**
**Common mistakes:**
**My explanation:**

---

## Vector Databases
**Date learned:**
**Why it exists:**
**Mental model:**
**How it works:**
**Common mistakes:**
**My explanation:**

EOF

# ─────────────────────────────────────────────────────────
# DECISIONS
# ─────────────────────────────────────────────────────────
cat > decisions/decision_log.md << 'EOF'
# Architecture Decision Log
> Every major technical decision logged here in ADR format

---

## ADR-001: Python/FastAPI over Go/Gin for backend
**Date:** June 2026
**Status:** Decided
**Context:** Building gaming café booking platform with a co-developer. Co-developer knows Python, not Go.
**Decision:** Use Python + FastAPI
**Reasoning:** Collaboration is more important than raw performance at this scale. FastAPI with async is fast enough. Co-developer can debug. Team velocity matters more than language benchmarks for an MVP.
**Alternatives rejected:**
  - Go/Gin: Faster, but co-developer can't contribute meaningfully to debugging
  - Node.js/Express: Neither developer's primary strength
**Consequences:** Must use async SQLAlchemy (not sync) to get performance benefits. Must run APScheduler in separate process.
**Reversibility:** Medium — rewriting in Go later is possible but painful. This is a real cost.

---

## ADR-002: Next.js PWA over React Native for customer app
**Date:** June 2026
**Status:** Decided
**Context:** Need a customer-facing app for booking. Original plan was React Native.
**Decision:** Next.js PWA (Progressive Web App)
**Reasoning:** PWA can be added to home screen, works offline for cached content, no App Store submission. For MVP validation, this is weeks faster. Real customers don't care if it's native at this stage.
**Alternatives rejected:**
  - React Native: Native feel, but weeks of setup, APK build complexity, no Play Store for early testing
  - Flutter: Neither developer's strength
**Consequences:** Push notifications via PWA are limited on iOS. Acceptable for MVP.
**Reversibility:** Easy — if PWA proves insufficient, React Native can be built with same API.

---

## ADR-003: Manual payout ledger over Razorpay Route
**Date:** June 2026
**Status:** Decided
**Context:** Need to pay café owners their share of revenue.
**Decision:** Manual payout tracking with a ledger table. Admin marks paid manually.
**Reasoning:** Razorpay Route requires KYC for every café — weeks of onboarding per café. For first 5 cafés, manual weekly bank transfers are acceptable. Build the digital infrastructure later when scale demands it.
**Alternatives rejected:**
  - Razorpay Route: Automated, cleaner, but complex café KYC onboarding blocks launch
**Consequences:** We must do weekly manual bank transfers to cafés. Doesn't scale past ~20 cafés.
**Reversibility:** Easy — the payout table structure already accommodates automated payments.

---

## ADR-004: {Title}
**Date:**
**Status:**
**Context:**
**Decision:**
**Reasoning:**
**Alternatives rejected:**
**Consequences:**
**Reversibility:**

EOF

cat > decisions/technology_choices.md << 'EOF'
# Technology Choices Reference
> Quick lookup: why we use each technology

| Technology | Why we chose it | What we gave up |
|------------|-----------------|-----------------|
| FastAPI | Async-native, auto docs, Python (team knows it) | Go's raw performance |
| PostgreSQL | ACID transactions, mature, great tooling | Redis's speed for everything |
| Redis | Atomic operations (SET NX), TTL native, fast | Persistence complexity |
| Alembic | Version-controlled migrations, auto-generate | Manual migration for complex changes |
| Next.js | Full-stack React, SSR, PWA support | True native feel |
| Razorpay | India-first, UPI support, Webhook API | Stripe's cleaner global API |
| Fast2SMS | Transactional route (DND-safe), cheap | WhatsApp API (higher conversion) |
| Docker Compose | Simple multi-service orchestration | Kubernetes (overkill for MVP) |

EOF

# ─────────────────────────────────────────────────────────
# ARCHITECTURE
# ─────────────────────────────────────────────────────────
cat > architecture/current_architecture.md << 'EOF'
# Current System Architecture
> Updated after every architectural change

**Last updated:** June 2026
**Current phase:** Pre-build (architecture complete, implementation not started)

---

## System Overview

```
Customer PWA (Next.js)          Admin Panel (Next.js)
       |                                |
       └──────────── HTTPS ─────────────┘
                         |
              FastAPI Backend (8000)
                    /        \
          PostgreSQL          Redis 7
          (primary data)      (locks + cache)
                    \
              Background Worker
              (APScheduler - separate container)
                    |
            ┌───────┴────────┐
         Razorpay         Fast2SMS
         (payments)       (SMS/OTP)
```

## Four Independent Services

| Service | Container | What it does |
|---------|-----------|--------------|
| api | api | FastAPI HTTP server, handles all API requests |
| worker | worker | APScheduler: slot generation, expiry, notifications |
| postgres | postgres | Primary database |
| redis | redis | Slot locking, caching, OTP storage, rate limiting |

**Why api and worker are separate:** If APScheduler runs inside the FastAPI process and the API restarts, the scheduler runs twice. Two instances = two slot generation crons = duplicate slots despite idempotency protection. Separation is non-negotiable.

---

## Request Flow: Booking Creation

```
1. Customer taps "Book"
2. POST /bookings/create hits API container
3. API checks Redis health (if down → 503, no booking)
4. API acquires slot lock in Redis (SET NX, TTL 120s or 2700s for UPI)
5. API creates Booking (status=pending) + Payment record in PostgreSQL (single transaction)
6. API creates Razorpay order via HTTP
7. API returns {booking_id, razorpay_order_id, expires_at} to client
8. Client shows Razorpay payment modal
9. User pays
10. Razorpay sends webhook to POST /payments/webhook
11. API verifies webhook signature
12. API checks idempotency (webhook_logs table)
13. API confirms booking, updates slot to "booked"
14. API sends confirmation SMS (fire and forget)
15. Worker separately: expires pending bookings where expires_at < now
```

---

## Layered Architecture

```
app/api/routes/     ← HTTP only. Parse request, call service, return response.
app/services/       ← Business logic. No HTTP knowledge. Calls models.
app/models/         ← Database structure. SQLAlchemy only.
app/schemas/        ← API contracts. Pydantic only.
app/core/           ← Shared infrastructure. DB, Redis, config, security.
app/workers/        ← Scheduled jobs. Never called from routes.
```

**Rule:** Routes never import from models directly. Routes only call services. Services import models. This means business logic is testable without HTTP.

---

## Changes from original plan
{Log any deviations from planned architecture here as you build}

EOF

cat > architecture/data_models.md << 'EOF'
# Database Data Models
> All tables, relationships, and design decisions

**Last updated:** June 2026

---

## Entity Relationship Summary

```
users ──< bookings >── slots >── pcs >── cafes
                |                          |
           payments              cafe_special_hours
                |
          webhook_logs

users ──< waitlist >── slots
cafes ──< payouts
bookings ──< booking_events
```

---

## Table: users
**Purpose:** All platform users across all roles
**Key design decisions:**
- `trust_score` float: decrements on no-shows, visible to admins
- `profile_index` int: allows 2 profiles per phone (father/son sharing)
- `ban_until` datetime: null = not banned, future datetime = banned until then

## Table: slots
**Purpose:** Individual bookable time blocks per PC per day
**Key design decisions:**
- `price_paise` is snapshotted at generation time — changing PC price doesn't affect existing slots
- UNIQUE constraint on (pc_id, date, start_time) — makes generation idempotent
- `cafe_id` is denormalized here (also on bookings) — avoids 3-join queries for admin dashboard

## Table: bookings
**Purpose:** Core booking record
**Key design decisions:**
- `version` int: optimistic locking — prevents admin race conditions
- `qr_base_secret`: HMAC secret for TOTP QR code generation
- `cafe_id` denormalized: admin "show today's bookings" doesn't need joins through slots→PCs

## Table: booking_events
**Purpose:** Immutable audit trail
**Key design decisions:**
- Never update, only insert
- `triggered_by`: "user", "admin", "system", "webhook" — required for dispute resolution
- Every status transition must write a row here

## Table: webhook_logs
**Purpose:** Idempotency and debugging for Razorpay webhooks
**Key design decisions:**
- `razorpay_event_id` UNIQUE — the idempotency key
- `processed` bool: two-step: insert with processed=False, then update to True after handling
- If server crashes between these two steps, log exists but booking not confirmed = detectable

---

{Full schema SQL will go here after Prompt 2 is complete}

EOF

cat > architecture/api_design.md << 'EOF'
# API Design
> Endpoint definitions, request/response shapes, design decisions

**Last updated:** June 2026

---

## Design Principles

1. **Resource-oriented URLs** — nouns not verbs (/bookings not /createBooking)
2. **Consistent error format** — all errors: `{error: string, code: string, detail: any}`
3. **No client-calculated money** — price always comes from server, never trusted from client
4. **Idempotency keys** — booking creation accepts idempotency key header
5. **Pagination on all list endpoints** — `?page=1&limit=20`

---

## Auth Endpoints

### POST /auth/send-otp
**Purpose:** Send OTP to phone
**Request:** `{phone: "9876543210", profile_index: 0}`
**Response:** `{message: "OTP sent", expires_in: 300}`
**Rate limit:** 3 per phone per 10 minutes
**Notes:** In dev, returns OTP in response for testing

### POST /auth/verify-otp
**Purpose:** Verify OTP, issue tokens
**Request:** `{phone: "9876543210", otp: "123456", profile_index: 0}`
**Response:** `{access_token, refresh_token, user: {id, phone, name, role}}`
**Notes:** Max 3 wrong attempts before lockout

---

## Booking Endpoints

### POST /bookings/create
**Purpose:** Create a booking (the most complex endpoint)
**Request:** `{slot_id: UUID, payment_method_hint: "upi" | "card" | null}`
**Response:** `{booking_id, razorpay_order_id, razorpay_key_id, amount_paise, expires_at, slot_details, qr_token}`
**Failure cases:**
- 409: Slot already locked
- 409: Booking already in progress for this user
- 422: Slot is in the past
- 429: Daily booking limit reached
- 503: Redis unavailable

---

{Continue adding endpoints as they are designed/built}

EOF

# ─────────────────────────────────────────────────────────
# PROJECT LOGS
# ─────────────────────────────────────────────────────────
cat > project_logs/gaming_cafe/status.md << 'EOF'
# Gaming Café Platform — Current Status
**Last updated:** June 2026

## What exists right now
- Architecture designed ✅
- Database schema designed ✅
- Edge cases documented ✅
- Execution plan created ✅
- Code: NOTHING YET

## Current phase
Pre-build — ready to start Prompt 1

## Health
🟡 Not started

## Known risks
1. APScheduler in wrong container (must be separate)
2. UPI pending state (extend lock to 45 min, not 2 min)
3. Webhook event ordering inversion (never reverse confirmed booking)
4. Razorpay KYC must be started Day 1 (2 lakh/month cap)

## Blocked on
Nothing — ready to build

EOF

cat > project_logs/gaming_cafe/implementation_log.md << 'EOF'
# Implementation Log — Gaming Café Platform
> What was built, when, and why decisions were made during implementation

---

## Entry format
```
### {Feature Name}
**Date:** {date}
**Prompt #:** {which prompt this was}
**What was built:** {description}
**Key decisions made during implementation:** {anything that deviated from plan}
**Concepts applied:** {what learning was used}
**What broke and how it was fixed:** {bugs encountered}
```

---

{Entries added as each feature is built}

EOF

cat > project_logs/gaming_cafe/bugs_and_fixes.md << 'EOF'
# Bugs & Fixes Log — Gaming Café Platform
> Issues encountered during development and how they were resolved

---

## Bug format
```
### Bug: {short title}
**Date:** {date}
**Symptom:** {what was observed}
**Root cause:** {why it happened}
**Fix:** {how it was resolved}
**Lesson:** {what to remember to prevent this}
**Category:** {async/database/redis/payment/logic/infrastructure}
```

---

{Entries added as bugs are encountered}

EOF

# ─────────────────────────────────────────────────────────
# MISTAKES
# ─────────────────────────────────────────────────────────
cat > mistakes/mistake_log.md << 'EOF'
# Mistake Log
> Patterns of errors and antipatterns caught during development
> Purpose: Identify recurring weaknesses and eliminate them

---

## Mistake format
```
### Pattern: {name}
**First seen:** {date}
**Times seen:** {count}
**Description:** {what the mistake looks like}
**Why it happens:** {root cause — usually a misconception}
**Correct approach:** {what to do instead}
**Status:** recurring / improving / resolved
```

---

## Pattern: Vibe Coding
**First seen:** {date}
**Times seen:** 0
**Description:** Generating or pasting code without being able to explain what it does
**Why it happens:** Speed pressure, AI assistance makes it easy to get working code without understanding
**Correct approach:** Stop. Read the code line by line. Explain each line out loud. If stuck, ask for explanation before continuing.
**Status:** watch

---

## Pattern: Missing Error Handling
**First seen:** {date}
**Times seen:** 0
**Description:** Writing happy path only, not handling the failure case
**Why it happens:** Optimism. "This won't fail." It will.
**Correct approach:** For every operation that can fail (DB, Redis, HTTP, payment), ask "what happens if this returns an error?"
**Status:** watch

---

## Pattern: Sync in Async
**First seen:** {date}
**Times seen:** 0
**Description:** Using blocking calls (requests.get, time.sleep, sync DB) inside async functions
**Why it happens:** Not understanding the event loop. Looks like it works until load.
**Correct approach:** In async functions: use httpx not requests, asyncio.sleep not time.sleep, async SQLAlchemy not sync
**Status:** watch

EOF

cat > mistakes/anti_patterns.md << 'EOF'
# Anti-Patterns Reference
> Things we explicitly decided NOT to do, and why

---

## Anti-Pattern: APScheduler inside FastAPI process
**Why it's wrong:** API restarts run the scheduler twice. Two cron instances = duplicate work despite idempotency.
**What to do instead:** Dedicated worker container running scheduler.py

## Anti-Pattern: Sync SQLAlchemy in FastAPI
**Why it's wrong:** Blocks the event loop. FastAPI routes can't serve other requests while waiting for DB.
**What to do instead:** async SQLAlchemy with asyncpg driver throughout.

## Anti-Pattern: Trusting client-provided price
**Why it's wrong:** Client can send any price. Always calculate price server-side from the Slot record.
**What to do instead:** Slot.price_paise is the source of truth. Ignore any price from request body.

## Anti-Pattern: Processing webhook without idempotency check
**Why it's wrong:** Razorpay retries webhooks. Processing twice = double confirmation, double refund, corruption.
**What to do instead:** Check webhook_logs.razorpay_event_id before processing anything.

## Anti-Pattern: Multi-table write without transaction
**Why it's wrong:** Server crashes between writes = inconsistent state. User charged but no booking. Slot booked but no payment.
**What to do instead:** Every operation that touches multiple tables goes inside an async with session.begin() block.

## Anti-Pattern: Hard-deleting records with related history
**Why it's wrong:** Breaks foreign key relationships. Destroys audit trail. Can't investigate disputes.
**What to do instead:** Soft delete with deleted_at timestamp. Filter deleted_at IS NULL in queries.

EOF

# ─────────────────────────────────────────────────────────
# CONCEPTS
# ─────────────────────────────────────────────────────────
cat > concepts/glossary.md << 'EOF'
# Technical Glossary
> Terms defined in my own words after learning them
> Rule: Don't add a term until you can define it without looking it up

---

## Idempotency
An operation is idempotent if applying it multiple times produces the same result as applying it once. A payment should be idempotent: charging a customer twice for the same order is a bug, not a feature. Implemented with unique keys that detect and skip duplicate requests.

## Event Loop
The heart of Python's async system. A single-threaded loop that manages concurrent tasks by switching between them at I/O boundaries. When a task says "await", it's handing control back to the loop to run something else. The loop never actually does two things at once — it just switches very fast.

## Race Condition
When the outcome depends on the sequence or timing of uncontrollable events. Two users booking the same slot simultaneously: if both check "is this slot free?" before either marks it as taken, both see "free" and both proceed — double booking. Fixed with atomic operations (Redis SET NX).

## Atomic Operation
An operation that either completes fully or not at all — nothing in between. Redis SET NX is atomic: check-and-set happens as one indivisible step, so two callers can never both see "not set" and both set it.

## Webhook
An HTTP callback. Instead of your app polling "did the payment succeed yet?", Razorpay calls YOUR endpoint when something happens. More efficient. Unreliable in that you don't control delivery timing or retries — hence idempotency requirements.

## Connection Pool
A cache of open database connections reused across requests. Opening a new DB connection is expensive (TLS handshake, auth, etc). A pool keeps N connections open and loans them out. If all are in use, new requests wait. pool_size and max_overflow tune this behaviour.

## Optimistic Locking
A concurrency strategy that assumes conflicts are rare. Each row has a version number. When updating, you specify the version you read: `WHERE id=X AND version=5`. If another process already updated it (version is now 6), your update affects 0 rows — you detect the conflict and retry.

## JWT (JSON Web Token)
A self-contained token that encodes user identity + claims + expiry, signed with a secret key. The server doesn't need to look up the session — it just verifies the signature. Stateless. The risk: you can't invalidate a valid JWT before it expires (hence short expiry + refresh token pattern).

## {Add new terms as you learn them}

EOF

cat > concepts/mental_models.md << 'EOF'
# Mental Models for Engineering
> Frameworks for thinking about common problems

---

## The Waiter Model (Async)
A sync program is a waiter who takes one order, goes to the kitchen, stands there watching food cook, brings it back, then takes the next order. An async program is a waiter who takes 20 orders, submits them all to the kitchen, and brings each dish out as it's ready. Same single person — radically different throughput.

## The Bathroom Key Model (Distributed Locking)
One key. One person at a time. To enter, you must hold the key. When you're done, you return the key. If you drop it and collapse, someone will find it eventually (TTL = the cleanup crew who checks after a timeout).

## The Ledger Model (Event Sourcing / Audit Logs)
A bank doesn't store "your balance is ₹5000." It stores every transaction: +₹1000 on Monday, -₹200 on Tuesday. The balance is computed from history. This means you can reconstruct any past state and audit any change. Our `booking_events` table is this ledger.

## The Snapshot vs Live Price Model
When you buy a flight ticket, the price is fixed at purchase time even if the flight's price changes tomorrow. Our slots snapshot the price at generation time. This prevents the nightmare of a customer paying ₹100, café changing price to ₹200, and the system being confused about what was agreed.

## The Circuit Breaker Model
An electrical circuit breaker trips when current exceeds safe levels — protecting the circuit. A software circuit breaker stops making calls to a failing service and returns fast errors instead of queuing up slow timeouts. Our booking endpoint returns 503 immediately if Redis is down rather than hanging.

## {Add new mental models as you discover them}

EOF

# ─────────────────────────────────────────────────────────
# INTERVIEW PREP
# ─────────────────────────────────────────────────────────
cat > interview_prep/weak_areas.md << 'EOF'
# Weak Areas — Study Tracker
> Honest self-assessment. Updated by Reflection Coach.

---

## Area format
```
### {Topic}
**First identified:** {date}
**Why it's hard:** {honest reason}
**Study approach:** {specific plan}
**Progress notes:** {what's improving}
**Status:** needs-work / improving / strong
```

---

### Async/Await Internals
**First identified:** Pre-build
**Why it's hard:** The event loop is invisible. Code looks sequential but isn't.
**Study approach:** Build a small demo: sync vs async DB queries under load. Measure difference.
**Progress notes:** Understand the concept, need to debug it under load
**Status:** needs-work

### Database Transactions and Isolation Levels
**First identified:** Pre-build
**Why it's hard:** Most tutorials skip isolation levels. The bugs they prevent are invisible until you have concurrent users.
**Study approach:** Deliberately cause a race condition without transactions, then fix it.
**Status:** needs-work

### System Design at Scale
**First identified:** Pre-build
**Why it's hard:** Hard to practice without real scale. Everything seems to work on localhost.
**Study approach:** Read "Designing Data-Intensive Applications" one chapter per week.
**Status:** needs-work

EOF

cat > interview_prep/questions_log.md << 'EOF'
# Interview Questions Log
> Questions practiced with strong answers logged here

---

## Question format
```
### Q: {Question}
**Category:** {system-design/coding/architecture/behavioral}
**Asked in context of:** {project/concept/interview}
**My answer:**
{answer in my own words}
**What I got right:**
**What I missed:**
**Strong answer:**
{the answer I'd give in an interview}
```

---

### Q: Why did you choose FastAPI over Django for your backend?
**Category:** architecture
**Asked in context of:** gaming café project decision
**My answer:** {fill during session when this question comes up}
**Strong answer:**
FastAPI is async-native, meaning it uses Python's event loop to handle concurrent I/O without threads. For a booking platform where most operations are DB queries and API calls (I/O-bound), this gives us high concurrency on a single process. Django's ORM is sync by default — you'd need Channels or ASGI wrappers to match this. FastAPI also gives us automatic OpenAPI documentation and Pydantic validation out of the box. For our scale and team, FastAPI was the cleaner choice.

---

### Q: How do you prevent double booking?
**Category:** system-design
**Asked in context of:** gaming café slot locking
**Strong answer:**
Redis SET NX (Set if Not eXists) is an atomic operation. When a user selects a slot, we attempt to set a key `slot_lock:{slot_id}` in Redis with a TTL. Because SET NX is atomic, only one caller can succeed — the race condition happens at the Redis level and Redis resolves it. The winner proceeds to create the booking; the loser gets a 409. We additionally update the slot's status in the database. The DB has a UNIQUE constraint on the status transition as a second safety net, but Redis is the primary lock mechanism because it's faster and doesn't require a DB round-trip.

---

### Q: What is idempotency and where did you apply it?
**Category:** architecture
**Asked in context of:** Razorpay webhooks
**Strong answer:**
{fill when we reach this concept in the build}

EOF

cat > interview_prep/system_design_practice.md << 'EOF'
# System Design Practice
> Problems worked through with architecture decisions

---

## Problem: Design a slot booking system (our actual project)

**Requirements:**
- Users can book 30-60 min PC slots at gaming cafés
- Multiple cafés, multiple PCs per café
- Real payments via UPI/card
- No double bookings
- Admin check-in via QR code

**Scale:**
- 50 cafés at launch, 500 eventually
- 200 concurrent users during peak (evenings)
- ~2000 bookings/day

**My design:**
{Walk through the architecture here after it's fully understood}

**Bottlenecks and how we addressed them:**
1. Double booking → Redis SET NX atomic locking
2. Slow slot queries → Redis cache per café per day
3. UPI payment delays → Extended lock TTL, polling Razorpay status
4. Webhook duplicates → Idempotency key in webhook_logs table

---

{Add more problems as they come up in learning or interviews}

EOF

# ─────────────────────────────────────────────────────────
# LINKEDIN CONTENT
# ─────────────────────────────────────────────────────────
cat > linkedin_content/content_ideas.md << 'EOF'
# LinkedIn Content Ideas
> Captured automatically by Content Detector during sessions

---

## Idea format
```
### {Title idea}
**Date captured:** {date}
**Category:** learning / build / mistake / milestone / insight / comparison
**The hook:** {first line — make someone stop scrolling}
**The story:** {what happened, 2-3 sentences}
**The insight:** {what this teaches other engineers}
**Proof:** {code / diagram / metric}
**Draft status:** idea / drafted / scheduled / published
```

---

### How UPI broke our entire booking system
**Date captured:** {to be filled}
**Category:** build
**The hook:** "Our slot booking TTL was 2 minutes. UPI payments can take 40 minutes. We shipped a double-booking bug before writing a single line of code."
**The story:** While designing the booking flow, we realized UPI transactions enter a "pending" state that can last up to 40 minutes due to bank server delays. Our slot lock TTL was 2 minutes. This would release the slot while the payment was still processing, allowing someone else to book the same slot — both payments would succeed.
**The insight:** Payment systems in India have UPI-specific edge cases that don't exist in Western payment systems. You have to design for them explicitly.
**Proof:** Architecture diagram showing the 45-minute UPI lock extension
**Draft status:** idea

---

### I designed an entire production system without writing code first
**Date captured:** {to be filled}
**Category:** milestone
**The hook:** "29 features. 11 database tables. 35 API endpoints. Zero lines of code written. This is the document that gets us there."
**The story:** Instead of jumping into code, we spent time designing the complete system: database schema, API contracts, edge cases, race conditions, payment flows. The result is a document that another developer could pick up and build from scratch.
**The insight:** The most expensive bugs are the ones baked into your architecture. Changing a database schema after 1000 users is 10x harder than changing it before writing line 1.
**Proof:** Link to the PRD / architecture document
**Draft status:** idea

EOF

cat > linkedin_content/draft_posts.md << 'EOF'
# Draft LinkedIn Posts
> Developed from content_ideas.md

---

{Drafts added as they are written}

EOF

cat > linkedin_content/published_posts.md << 'EOF'
# Published Posts
> Record of what's been posted

| Date | Title | Hook | Engagement |
|------|-------|------|------------|
| {date} | {title} | {first line} | {likes/comments} |

EOF

# ─────────────────────────────────────────────────────────
# REFLECTION
# ─────────────────────────────────────────────────────────
cat > reflection/weekly_review.md << 'EOF'
# Weekly Learning Reviews
> Written at end of each week, updated by Reflection Coach

---

## Week of {date}

**What I built:**

**What I learned (concepts):**

**What was harder than expected:**

**What became clear that was confusing before:**

**Mistakes made this week:**

**What I want to be stronger at next week:**

**One thing I could explain to a junior engineer now that I couldn't a week ago:**

---

{Add new week below each entry}

EOF

cat > reflection/growth_tracker.md << 'EOF'
# Engineering Growth Tracker
> Honest skill assessment over time

---

## Rating scale
1 = Never heard of it
2 = Know what it is, can't implement
3 = Can implement with help/reference
4 = Can implement independently
5 = Can explain tradeoffs and teach others

---

## June 2026 baseline

| Skill | Rating | Notes |
|-------|--------|-------|
| Python fundamentals | 3 | Can write it, some gaps in internals |
| Async Python | 2 | Use it, don't fully understand event loop |
| FastAPI | 2 | Built with it, can't explain all decisions |
| PostgreSQL | 2 | Basic queries, no deep indexing/transaction knowledge |
| Redis | 1 | Know it exists, haven't used it deeply |
| System design | 2 | Intuitive, not structured |
| Software architecture | 2 | Can follow patterns, can't create them |
| API design | 2 | Build APIs, not systematic about it |
| Testing | 1 | Rarely write tests |
| Docker | 2 | Use Docker Compose, don't understand deeply |
| Git advanced | 2 | Basic commits/branches |
| AI engineering | 1 | Interest but no implementation experience |

## {Month Year} reassessment
{Add new row after completing each major feature or study block}

EOF

# ─────────────────────────────────────────────────────────
# FUTURE IMPROVEMENTS
# ─────────────────────────────────────────────────────────
cat > future_improvements/backlog.md << 'EOF'
# Feature Backlog
> Ideas captured but explicitly deferred from MVP

---

## Format
```
### {Feature name}
**Captured:** {date}
**Why deferred:** {specific reason — not "we'll do it later"}
**Trigger for building:** {what event would make this worth building now}
**Estimated complexity:** low/medium/high
```

---

### Razorpay Route (automated café payouts)
**Captured:** June 2026
**Why deferred:** Requires KYC onboarding for every café. Blocks fast café acquisition.
**Trigger for building:** When manually managing payouts for 10+ cafés becomes unsustainable
**Estimated complexity:** medium

### React Native App
**Captured:** June 2026
**Why deferred:** PWA sufficient for MVP validation. Native feel not required to prove concept.
**Trigger for building:** When PWA push notification limitations cause meaningful user drop-off
**Estimated complexity:** high

### Group Booking
**Captured:** June 2026
**Why deferred:** Requires PC adjacency data and complex simultaneous locking
**Trigger for building:** User research shows friend groups are a primary booking pattern
**Estimated complexity:** high

### Dynamic Last-Minute Pricing
**Captured:** June 2026
**Why deferred:** Phase 2 feature. MVP needs to validate basic booking first.
**Trigger for building:** After 500 bookings/month baseline, test price elasticity
**Estimated complexity:** low

EOF

cat > future_improvements/tech_debt.md << 'EOF'
# Technical Debt Log
> Shortcuts taken and why, with plan to address

---

## Format
```
### {Debt item}
**Created:** {date}
**Why it was created:** {reason — be honest}
**Impact:** {what gets worse if not addressed}
**Fix:** {what needs to be done}
**Priority:** low/medium/high
```

---

{Entries added during implementation when shortcuts are taken}

EOF

echo ""
echo "✅ Engineering OS folder structure created successfully!"
echo ""
echo "Structure created:"
find . -name "*.md" | sort | head -50
EOF
