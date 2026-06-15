import uuid
from datetime import datetime
from enum import Enum as PyEnum
from typing import Optional

from sqlalchemy import Integer, String, ForeignKey, DateTime, Enum, text
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import UUID, TSTZRANGE, ExcludeConstraint

class Base(DeclarativeBase):
    pass

# -----------------
# ENUMS
# -----------------
class PCStatus(str, PyEnum):
    ONLINE = "online"
    MAINTENANCE = "maintenance"

class BookingStatus(str, PyEnum):
    PENDING = "pending"
    CONFIRMED = "confirmed"
    ACTIVE = "active"
    COMPLETED = "completed"
    CANCELLED = "cancelled"

class PaymentStatus(str, PyEnum):
    PENDING = "pending"
    PAID_ONLINE = "paid_online"
    PAID_CASH = "paid_cash"

class StaffRole(str, PyEnum):
    OWNER = "owner"
    MANAGER = "manager"
    STAFF = "staff"

# -----------------
# MODELS
# -----------------
class User(Base):
    __tablename__ = "users"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email: Mapped[str] = mapped_column(String, unique=True, index=True)
    auth_provider: Mapped[str] = mapped_column(String)
    
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=text("now()"))


class Cafe(Base):
    __tablename__ = "cafes"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name: Mapped[str] = mapped_column(String)
    timezone: Mapped[str] = mapped_column(String) # e.g. "Asia/Kolkata"
    
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=text("now()"))


class CafeStaff(Base):
    __tablename__ = "cafe_staff"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    cafe_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("cafes.id", ondelete="CASCADE"), index=True)
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    role: Mapped[StaffRole] = mapped_column(Enum(StaffRole, name="staff_role_enum"))
    
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=text("now()"))


class PCTier(Base):
    __tablename__ = "pc_tiers"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    cafe_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("cafes.id", ondelete="CASCADE"), index=True)
    name: Mapped[str] = mapped_column(String)
    total_quantity: Mapped[int] = mapped_column(Integer)
    hourly_rate_paise: Mapped[int] = mapped_column(Integer)
    
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=text("now()"))


class PhysicalPC(Base):
    __tablename__ = "physical_pcs"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    cafe_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("cafes.id", ondelete="CASCADE"), index=True)
    tier_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("pc_tiers.id", ondelete="CASCADE"), index=True)
    pc_number: Mapped[str] = mapped_column(String)
    status: Mapped[PCStatus] = mapped_column(Enum(PCStatus, name="pc_status_enum"), default=PCStatus.ONLINE)


class Booking(Base):
    __tablename__ = "bookings"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    cafe_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("cafes.id", ondelete="CASCADE"), index=True)
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    tier_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("pc_tiers.id", ondelete="RESTRICT"), index=True)
    
    # Time Range
    booking_time: Mapped[str] = mapped_column(TSTZRANGE, nullable=False)
    
    status: Mapped[BookingStatus] = mapped_column(Enum(BookingStatus, name="booking_status_enum"), default=BookingStatus.PENDING)
    
    # Financials
    total_amount_paise: Mapped[int] = mapped_column(Integer)
    payment_status: Mapped[PaymentStatus] = mapped_column(Enum(PaymentStatus, name="payment_status_enum"), default=PaymentStatus.PENDING)

    # Walk-in / Check-in claims
    qr_code_token: Mapped[str] = mapped_column(String, unique=True, index=True)
    assigned_pc_id: Mapped[Optional[uuid.UUID]] = mapped_column(ForeignKey("physical_pcs.id", ondelete="SET NULL"), nullable=True, index=True)
    
    # Audit Trail for Disputes
    claimed_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)
    claimed_by_staff_id: Mapped[Optional[uuid.UUID]] = mapped_column(ForeignKey("cafe_staff.id", ondelete="SET NULL"), nullable=True, index=True)

    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=text("now()"))

    __table_args__ = (
        ExcludeConstraint(
            ("assigned_pc_id", "="),
            ("booking_time", "&&"),
            where=text("assigned_pc_id IS NOT NULL"),
            name="exclude_overlapping_pcs",
            using="gist" # Requires btree_gist extension in Postgres
        ),
    )
