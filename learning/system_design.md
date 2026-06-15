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

