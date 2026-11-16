from datetime import datetime
from typing import ClassVar

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

    # Fields a client may blank out again on an edit. name, category and
    # reminderEnabled always need a value, so a null for those is ignored.
    CLEARABLE: ClassVar[tuple[str, ...]] = ("brand", "modelNumber", "price", "purchaseDate", "warrantyDurationMonths", "serviceDate", "notes")

    def cleared_fields(self) -> list[str]:
        """Fields the request explicitly set to null ("remove this value"),
        as opposed to fields it simply left out ("leave unchanged")."""
        return [f for f in self.CLEARABLE if f in self.model_fields_set and getattr(self, f) is None]
