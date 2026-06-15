# Architecture Decision Log
> Every major technical decision logged here in ADR format

---

## ADR-001: Python/FastAPI over Go/Gin for backend
**Date:** June 2026
**Status:** Decided
**Context:** Building gaming café booking platform with a co-developer. Co-developer knows Python, not Go.
**Decision:** Use Python + FastAPI
**Reasoning:** Collaboration is more important than raw performance at this scale. FastAPI with async is fast enough. Co-developer can debug. Team velocity matters more than language benchmarks for an MVP.
**Alternatives rejected:**
  - Go/Gin: Faster, but co-developer can't contribute meaningfully to debugging
  - Node.js/Express: Neither developer's primary strength
**Consequences:** Must use async SQLAlchemy (not sync) to get performance benefits. Must run APScheduler in separate process.
**Reversibility:** Medium — rewriting in Go later is possible but painful. This is a real cost.

---

## ADR-002: Next.js PWA over React Native for customer app
**Date:** June 2026
**Status:** Decided
**Context:** Need a customer-facing app for booking. Original plan was React Native.
**Decision:** Next.js PWA (Progressive Web App)
**Reasoning:** PWA can be added to home screen, works offline for cached content, no App Store submission. For MVP validation, this is weeks faster. Real customers don't care if it's native at this stage.
**Alternatives rejected:**
  - React Native: Native feel, but weeks of setup, APK build complexity, no Play Store for early testing
  - Flutter: Neither developer's strength
**Consequences:** Push notifications via PWA are limited on iOS. Acceptable for MVP.
**Reversibility:** Easy — if PWA proves insufficient, React Native can be built with same API.

---

## ADR-003: Manual payout ledger over Razorpay Route
**Date:** June 2026
**Status:** Decided
**Context:** Need to pay café owners their share of revenue.
**Decision:** Manual payout tracking with a ledger table. Admin marks paid manually.
**Reasoning:** Razorpay Route requires KYC for every café — weeks of onboarding per café. For first 5 cafés, manual weekly bank transfers are acceptable. Build the digital infrastructure later when scale demands it.
**Alternatives rejected:**
  - Razorpay Route: Automated, cleaner, but complex café KYC onboarding blocks launch
**Consequences:** We must do weekly manual bank transfers to cafés. Doesn't scale past ~20 cafés.
**Reversibility:** Easy — the payout table structure already accommodates automated payments.

---

## ADR-004: {Title}
**Date:**
**Status:**
**Context:**
**Decision:**
**Reasoning:**
**Alternatives rejected:**
**Consequences:**
**Reversibility:**

