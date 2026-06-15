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

