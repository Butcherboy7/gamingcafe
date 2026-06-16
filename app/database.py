import os
from typing import AsyncGenerator
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession

# Dynamic database URL configuration. 
# Defaults to localhost asyncpg driver connection.
DATABASE_URL = os.getenv(
    "DATABASE_URL", 
    "postgresql+asyncpg://postgres:postgres@localhost:5432/gamingcafe"
)

# Create the asynchronous database engine
engine = create_async_engine(
    DATABASE_URL,
    echo=True,               # Set to True to log generated SQL statements in development
    future=True,             # Ensures SQLAlchemy 2.0 behaviors
)

# Configure the session maker to produce AsyncSession instances
async_session_maker = async_sessionmaker(
    bind=engine,
    class_=AsyncSession,
    expire_on_commit=False,  # Prevents SQLAlchemy from expiring attributes after commit
)

# Dependency to provide AsyncSession to routes and close it on completion
async def get_db() -> AsyncGenerator[AsyncSession, None]:
    async with async_session_maker() as session:
        try:
            yield session
        finally:
            await session.close()
