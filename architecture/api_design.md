# API Design
> Endpoint definitions, request/response shapes, design decisions

**Last updated:** June 2026

---

## Design Principles

1. **Resource-oriented URLs** — nouns not verbs (/bookings not /createBooking)
2. **Consistent error format** — all errors: `{error: string, code: string, detail: any}`
3. **No client-calculated money** — price always comes from server, never trusted from client
4. **Idempotency keys** — booking creation accepts idempotency key header
5. **Pagination on all list endpoints** — `?page=1&limit=20`

---

## Auth Endpoints

### POST /auth/send-otp
**Purpose:** Send OTP to phone
**Request:** `{phone: "9876543210", profile_index: 0}`
**Response:** `{message: "OTP sent", expires_in: 300}`
**Rate limit:** 3 per phone per 10 minutes
**Notes:** In dev, returns OTP in response for testing

### POST /auth/verify-otp
**Purpose:** Verify OTP, issue tokens
**Request:** `{phone: "9876543210", otp: "123456", profile_index: 0}`
**Response:** `{access_token, refresh_token, user: {id, phone, name, role}}`
**Notes:** Max 3 wrong attempts before lockout

---

## Booking Endpoints

### POST /bookings/create
**Purpose:** Create a booking (the most complex endpoint)
**Request:** `{slot_id: UUID, payment_method_hint: "upi" | "card" | null}`
**Response:** `{booking_id, razorpay_order_id, razorpay_key_id, amount_paise, expires_at, slot_details, qr_token}`
**Failure cases:**
- 409: Slot already locked
- 409: Booking already in progress for this user
- 422: Slot is in the past
- 429: Daily booking limit reached
- 503: Redis unavailable

---

{Continue adding endpoints as they are designed/built}

