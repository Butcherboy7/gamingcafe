from fastapi import FastAPI, Depends
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db

app = FastAPI(
    title="Gaming Café Booking Platform API",
    description="Backend API for managing café tenants, PC tiers, bookings, and payments",
    version="1.0.0"
)

@app.get("/health", tags=["Health"])
async def health_check(db: AsyncSession = Depends(get_db)):
    """
    Verifies that the API server is running and successfully connected to 
    the PostgreSQL database by executing a simple SELECT query.
    """
    try:
        # Perform a quick database ping to check connectivity
        await db.execute(text("SELECT 1"))
        return {
            "status": "healthy",
            "database": "connected",
            "message": "Gaming Café Booking Platform API is operational"
        }
    except Exception as e:
        return {
            "status": "unhealthy",
            "database": f"connection_failed: {str(e)}",
            "message": "Gaming Café Booking Platform API is running but database is unreachable"
        }
