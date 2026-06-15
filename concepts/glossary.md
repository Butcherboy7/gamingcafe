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

