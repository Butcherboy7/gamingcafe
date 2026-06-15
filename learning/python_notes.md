# Python Deep Dive Notes
> Updated automatically by Learning Coach during sessions

---

## How to use this file
Each entry follows: concept → why it exists → mental model → internals → mistakes → project usage → my explanation

---

## Async / Await
**Date learned:**
**Why it exists:** Python is single-threaded. Without async, one slow I/O operation (DB query, HTTP call) blocks the entire program. Async allows the interpreter to work on other things while waiting.
**Mental model:** A waiter who takes your order, goes to the kitchen (starts cooking = I/O), then serves other tables while your food is being prepared. Never stands still waiting.
**How it works:** The event loop is a scheduler. `await` tells it "I'm waiting for I/O, go do something else." The coroutine is paused and resumed when the I/O completes.
**Common mistakes:**
  - Calling a sync blocking function inside async code (blocks the whole event loop)
  - Forgetting `await` keyword (returns a coroutine object, not the result)
  - Using `time.sleep()` instead of `asyncio.sleep()` inside async functions
**Used in our project:** Every FastAPI route, every SQLAlchemy query, every Redis call
**My explanation (Uzair's words):** {fill after teaching session}

---

## Generators and Iterators
**Date learned:**
**Why it exists:**
**Mental model:**
**How it works:**
**Common mistakes:**
**Used in our project:**
**My explanation:**

---

## Type Hints and Pydantic
**Date learned:**
**Why it exists:**
**Mental model:**
**How it works:**
**Common mistakes:**
**Used in our project:**
**My explanation:**

---

## Decorators
**Date learned:**
**Why it exists:**
**Mental model:**
**How it works:**
**Common mistakes:**
**Used in our project:**
**My explanation:**

---

## Context Managers (with statement)
**Date learned:**
**Why it exists:**
**Mental model:**
**How it works:**
**Common mistakes:**
**Used in our project:**
**My explanation:**

