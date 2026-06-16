from datetime import datetime
from uuid import UUID
from typing import Optional, Any
from pydantic import BaseModel, Field, ConfigDict, model_validator
from app.models.models import BookingStatus, PaymentStatus

class BookingBase(BaseModel):
    cafe_id: UUID = Field(..., description="The ID of the café where the booking is made")
    user_id: UUID = Field(..., description="The ID of the user making the booking")
    tier_id: UUID = Field(..., description="The ID of the PC tier (e.g. VIP, Regular) booked")

class BookingCreate(BookingBase):
    start_time: datetime = Field(..., description="The timezone-aware start time of the booking (stored in UTC)")
    end_time: datetime = Field(..., description="The timezone-aware end time of the booking (stored in UTC)")

    @model_validator(mode="after")
    def validate_times(self) -> "BookingCreate":
        if self.start_time >= self.end_time:
            raise ValueError("end_time must be after start_time")
        if self.start_time < datetime.now(self.start_time.tzinfo or None):
            raise ValueError("start_time cannot be in the past")
        return self

class BookingResponse(BookingBase):
    id: UUID
    status: BookingStatus
    total_amount_paise: int
    payment_status: PaymentStatus
    qr_code_token: str
    assigned_pc_id: Optional[UUID] = None
    claimed_at: Optional[datetime] = None
    claimed_by_staff_id: Optional[UUID] = None
    created_at: datetime
    
    # We expose distinct fields to JSON clients instead of a Postgres range object
    start_time: datetime
    end_time: datetime

    # Configures Pydantic to read fields from ORM models (previously orm_mode=True)
    model_config = ConfigDict(from_attributes=True)

    @model_validator(mode="before")
    @classmethod
    def extract_range_bounds(cls, data: Any) -> Any:
        """
        PostgreSQL stores booking time as a TSTZRANGE range. SQLAlchemy / asyncpg
        presents this as a Range object (possessing .lower and .upper) or a tuple.
        This validator extracts the lower and upper bounds of booking_time and sets them
        as start_time and end_time before Pydantic serializes the data.
        """
        if not isinstance(data, dict):
            # Processing SQLAlchemy ORM object
            bt = getattr(data, "booking_time", None)
            if bt is not None:
                lower = getattr(bt, "lower", None)
                upper = getattr(bt, "upper", None)
                if lower is None or upper is None:
                    if isinstance(bt, (tuple, list)) and len(bt) == 2:
                        lower, upper = bt[0], bt[1]
                setattr(data, "start_time", lower)
                setattr(data, "end_time", upper)
        else:
            # Processing raw dictionary
            bt = data.get("booking_time")
            if bt is not None:
                lower = getattr(bt, "lower", None)
                upper = getattr(bt, "upper", None)
                if lower is None or upper is None:
                    if isinstance(bt, (tuple, list)) and len(bt) == 2:
                        lower, upper = bt[0], bt[1]
                data["start_time"] = lower
                data["end_time"] = upper
        return data
