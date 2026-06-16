# Implementation Log — Gaming Café Platform
> What was built, when, and why decisions were made during implementation

---

## Entry format
```
### {Feature Name}
**Date:** {date}
**Prompt #:** {which prompt this was}
**What was built:** {description}
**Key decisions made during implementation:** {anything that deviated from plan}
**Concepts applied:** {what learning was used}
**What broke and how it was fixed:** {bugs encountered}
```

---

### Database Migration Scaffolding (Alembic & Docker Setup)
**Date:** 2026-06-16
**Prompt #:** 1 (Database Initialization)
**What was built:** 
- Configured and initialized Alembic using the `async` template (`env.py` and `alembic.ini`).
- Wrote the initial database migration script `e6edd257a7ab_initial_schema.py` mapping our 6 main tables.
- Wrote `docker-compose.yml` to launch local PostgreSQL 16 and Redis containers.
**Key decisions made during implementation:** 
- Configured dynamic database URLs in `env.py` loading from environment variables (`DATABASE_URL`) with an asyncpg localhost fallback.
- Manually coded the migration script instead of auto-generating to avoid dependency on running database engines and to enforce correct custom type operations.
**Concepts applied:** Async SQLAlchemy configuration, version-controlled database migrations, PostgreSQL exclusion constraints using GiST indexes, and enabling PostgreSQL extensions (`btree_gist`) in migration scripts.
**What broke and how it was fixed:** 
- Initially identified that Docker is not installed on the system. Decided to create a self-contained, pre-written migration script that is fully operational and runnable once the user starts their DB service, ensuring no connection blockers.

---

### FastAPI Scaffolding & Booking validation Schemas
**Date:** 2026-06-16
**Prompt #:** 2 (FastAPI scaffolding and validation)
**What was built:** 
- Created `app/main.py` scaffolding the FastAPI entrypoint and a database-pinging health endpoint.
- Created `app/database.py` with SQLAlchemy `create_async_engine`, `async_sessionmaker`, and the dependency generator `get_db`.
- Created `app/schemas.py` declaring Pydantic `BookingCreate` and `BookingResponse` schemas.
**Key decisions made during implementation:** 
- Exposed separate `start_time` and `end_time` datetimes to client JSON instead of raw postgres range types. Added custom `@model_validator(mode="before")` inside `BookingResponse` to unpack range boundaries dynamically from the database range object.
**Concepts applied:** Pydantic v2 `ConfigDict(from_attributes=True)` mappings, validation lifecycle, model separation of concerns, and async session management in FastAPI dependencies.
**What broke and how it was fixed:** 
- None. Ensured correct import verification of `app.main` with a clean mock run.



