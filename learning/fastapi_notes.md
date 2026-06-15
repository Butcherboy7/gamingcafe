# FastAPI Deep Dive Notes
> Updated automatically by Learning Coach during sessions

---

## Dependency Injection
**Date learned:**
**Why it exists:** To share resources (DB sessions, Redis connections, current user) across routes without global state or repetitive code.
**Mental model:** FastAPI automatically creates and passes "dependencies" to route functions. You declare what you need, FastAPI figures out how to provide it.
**How it works:** FastAPI inspects function signatures. Anything typed as `Depends(something)` gets resolved before your function runs. Depends can depend on other Depends — it's a DAG.
**Common mistakes:**
  - Creating a DB session per request without closing it (use async generator pattern)
  - Making dependencies that do too much (keep them focused)
  - Not handling async dependencies properly
**Used in our project:** `get_db()`, `get_redis()`, `get_current_user()`, `require_cafe_admin()`
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
**Date learned:**
**Why it exists:** Two different jobs. SQLAlchemy models describe the database. Pydantic models describe the API interface. They should NOT be the same thing.
**Mental model:** SQLAlchemy = blueprint of storage. Pydantic = contract with the client. Conflating them means your DB structure leaks into your API or vice versa.
**How it works:** You create SQLAlchemy models for the ORM, Pydantic schemas for request/response. Map between them manually or with orm_mode.
**Common mistakes:**
  - Using SQLAlchemy models as response models (exposes internal fields)
  - Forgetting `from_orm=True` / `model_validate` when converting
**Used in our project:** Every endpoint has separate schema classes
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

