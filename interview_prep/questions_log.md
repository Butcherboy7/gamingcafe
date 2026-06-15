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

