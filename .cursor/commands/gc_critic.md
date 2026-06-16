---
description: Perform a hostile code review on the active Gaming Café backend or frontend code
---
1. Act as a Staff Engineer reviewing the Gaming Café Booking Platform implementation.
2. Scan all modified/new files specifically for these critical operational risks:
   - **Sync in Async**: Blocking functions (like `time.sleep`, synchronous DB drivers, synchronous requests) inside async routes/services.
   - **Double Booking / Race Conditions**: Incomplete or non-atomic Redis slot locking (`SET NX` with no TTL or unsafe unlock).
   - **Webhook Vulnerabilities**: Missing Razorpay signature verification, missing idempotency check (using `webhook_logs` table), or unsafe transaction rollback.
   - **SQLAlchemy Pitfalls**: N+1 queries, unbounded queries, missing ACID transactions on multi-table writes.
   - **Version/State Races**: Missing optimistic locking check on the bookings table.
   - **Validation Bypass**: Missing Pydantic input sanitization, database defaults leaking, or client-supplied pricing.
3. Output a ranked list of real operational risks with exact line numbers. Zero style comments.
