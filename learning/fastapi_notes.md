# FastAPI Deep Dive Notes
> Updated automatically by Learning Coach during sessions

---

## Dependency Injection
**Date learned:** 2026-06-16
**Why it exists:** To share resources (DB sessions, Redis connections, current user) across routes without global state or repetitive code.
**Mental model:** FastAPI automatically creates and passes "dependencies" to route functions. You declare what you need, FastAPI figures out how to provide it.
**How it works:** FastAPI inspects function signatures. Anything typed as `Depends(something)` gets resolved before your function runs. Depends can depend on other Depends — it's a DAG.
**Common mistakes:**
  - Creating a DB session per request without closing it (use async generator pattern)
  - Making dependencies that do too much (keep them focused)
  - Not handling async dependencies properly
**Used in our project:** `get_db()` async generator in `app/database.py` yields DB sessions to endpoints and automatically closes them in a `finally` block.
**My explanation:**

---

## Request Lifecycle
**Date learned:**
**Why it exists:**
**Mental model:**
**How it works:**
**Common mistakes:**
**Used in our project:**
**My explanation:**

---

## Background Tasks
**Date learned:**
**Why it exists:**
**Mental model:**
**How it works:**
**Common mistakes:**
**Used in our project:**
**My explanation:**

---

## Pydantic Models vs SQLAlchemy Models
**Date learned:** 2026-06-16
**Why it exists:** Separates database storage concerns from API contract concerns. Forces clean validation before database interaction and hides sensitive fields on responses.
**Mental model:** SQLAlchemy = how we store the data in the physical file drawer. Pydantic = the application form the user submits, or the public receipt we print out. They serve different purposes.
**How it works:** SQLAlchemy structures tables, types, and constraints (like ranges). Pydantic parses incoming JSON bodies (converting strings to datetime and verifying constraints) and serializes outgoing SQLAlchemy objects into clean JSON.
**Common mistakes:**
  - Exposing internal database fields (like `qr_code_token` or keys) to users by returning raw SQLAlchemy models directly.
  - Relying on SQLAlchemy to catch format/type errors (causes DB crashes/transactions aborting) instead of filtering them at the boundary with Pydantic.
**Used in our project:** Created `BookingCreate` for parsing incoming payloads and `BookingResponse` with a `@model_validator` to extract PostgreSQL range elements (`lower`/`upper`) into flat `start_time` and `end_time` parameters.
**My explanation:**

---

## Middleware
**Date learned:**
**Why it exists:**
**Mental model:**
**How it works:**
**Common mistakes:**
**Used in our project:**
**My explanation:**

---

## Exception Handling
**Date learned:**
**Why it exists:**
**Mental model:**
**How it works:**
**Common mistakes:**
**Used in our project:**
**My explanation:**

