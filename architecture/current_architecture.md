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

