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

