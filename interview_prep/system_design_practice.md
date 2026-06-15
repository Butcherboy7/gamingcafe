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

