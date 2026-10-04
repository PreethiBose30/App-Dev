from datetime import datetime

from pydantic import BaseModel, Field


class AssetBody(BaseModel):
    """Shared by create and update -- POST additionally requires `name` to
    be non-empty (checked in the router, since PUT allows omitting it
    entirely to leave that field unchanged)."""

    name: str | None = Field(default=None, min_length=1)
    category: str | None = None
    brand: str | None = None
    modelNumber: str | None = None
    price: float | None = Field(default=None, ge=0)
    purchaseDate: datetime | None = None
    warrantyDurationMonths: int | None = Field(default=None, ge=0)
    serviceDate: datetime | None = None
    notes: str | None = None
    reminderEnabled: bool | None = None

    def to_update_dict(self) -> dict:
        return {k: v for k, v in self.model_dump().items() if v is not None}
