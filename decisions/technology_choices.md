# Technology Choices Reference
> Quick lookup: why we use each technology

| Technology | Why we chose it | What we gave up |
|------------|-----------------|-----------------|
| FastAPI | Async-native, auto docs, Python (team knows it) | Go's raw performance |
| PostgreSQL | ACID transactions, mature, great tooling | Redis's speed for everything |
| Redis | Atomic operations (SET NX), TTL native, fast | Persistence complexity |
| Alembic | Version-controlled migrations, auto-generate | Manual migration for complex changes |
| Next.js | Full-stack React, SSR, PWA support | True native feel |
| Razorpay | India-first, UPI support, Webhook API | Stripe's cleaner global API |
| Fast2SMS | Transactional route (DND-safe), cheap | WhatsApp API (higher conversion) |
| Docker Compose | Simple multi-service orchestration | Kubernetes (overkill for MVP) |

