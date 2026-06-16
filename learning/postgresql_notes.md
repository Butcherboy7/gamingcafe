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
**Date learned:** 2026-06-16
**Why it exists:** Database schemas evolve over time. Hand-written SQL alter tables are error-prone and hard to track across development/production environments. Migrations provide version-controlled, reproducible database evolution.
**Mental model:** Git commit history for your database schema. Upgrades go forward; downgrades roll back.
**How it works:** Alembic uses an engine connection and reads the model metadata from Python. It computes diffs between models and the actual DB state, producing migration scripts inside `alembic/versions/`.
**Common mistakes:**
  - Auto-generating and running migrations without manual review (autogenerate can miss custom extensions, indexes, or drop tables unexpectedly).
  - Diverging database state by executing manual DDL commands directly on PostgreSQL instead of through migrations.
**Used in our project:** Scaffolded the initial async Alembic migration (`e6edd257a7ab_initial_schema.py`) to create our 6 tables.
**My explanation:** 

---

## PostgreSQL Range Types and btree_gist Extension
**Date learned:** 2026-06-16
**Why it exists:** Traditional queries check simple scalar bounds (`start_time <= check_time AND end_time >= check_time`). This is verbose and slow to query/index. Range types store start and end values as a single entity.
**Mental model:** A time range is like a physical block. Checking if two blocks collide (overlap) uses a specialized range overlap operator (`&&`).
**How it works:** PostgreSQL native `TSTZRANGE` column represents a timezone-aware timestamp range. To index overlap checks, Postgres uses GiST (Generalized Search Tree) indexes.
However, we want to combine scalar equality (`assigned_pc_id = :pc_id`) and range overlap (`booking_time && :booking_time`) in a single exclusion index. Since standard GiST indexes do not support scalar operations (like equals on UUID), we enable the `btree_gist` extension to bridge this gap.
**Common mistakes:**
  - Forgetting to create the extension (`CREATE EXTENSION IF NOT EXISTS btree_gist;`) before creating tables with exclusion constraints, causing migration failures.
**Used in our project:** Applied in `exclude_overlapping_pcs` exclusion constraint on the `bookings` table to prevent booking collisions on physical PCs.
**My explanation:** 

