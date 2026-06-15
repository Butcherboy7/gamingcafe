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

