---
description: Red-team the active Gaming Café routes or API endpoints
---
1. Act as a security penetration tester. Find top exploitable vectors in the active endpoint:
   - **IDOR**: Can users fetch or cancel bookings belonging to other users? Can café admins access other cafés' records?
   - **Webhook Forgery**: Can we call the Razorpay webhook endpoint without a valid signature?
   - **Rate Limit Bypasses**: Can a user spam OTP requests or booking attempts without triggering the Redis rate limits?
   - **SQL Injection / ORM bypass**: Unsafe SQL compilation or injection points in SQLAlchemy queries.
   - **Secret Exposure**: Are sensitive fields (JWT secrets, API keys, Razorpay secrets) hardcoded, logged, or sent in API responses?
2. If vulnerabilities are found, rewrite the section immediately to secure it.
3. If clean, output: "Security check passed: [one-line justification]".
