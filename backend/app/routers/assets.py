import re
from datetime import datetime, timezone

from bson import ObjectId
from fastapi import APIRouter, Depends, HTTPException

from .. import database
from ..dependencies import CurrentUser, get_current_user, load_owned
from ..models.asset import AssetBody
from ..utils import oid_str, serialize_asset, to_object_id
from .documents import delete_file_for_doc

router = APIRouter(prefix="/api/v1/assets", tags=["assets"])

ASSET_FIELDS = [
    "name", "category", "brand", "modelNumber", "price",
    "purchaseDate", "warrantyDurationMonths", "serviceDate",
    "notes", "reminderEnabled",
]


def _compute_warranty_expiry(doc: dict) -> None:
    """Mirrors the Node Asset schema's pre('save') hook."""
    purchase_date = doc.get("purchaseDate")
    months = doc.get("warrantyDurationMonths") or 0
    if purchase_date and months > 0:
        month_index = purchase_date.month - 1 + months
        year = purchase_date.year + month_index // 12
        month = month_index % 12 + 1
        try:
            doc["warrantyExpiry"] = purchase_date.replace(year=year, month=month)
        except ValueError:
            # e.g. Jan 31 + 1 month -> Feb 31 doesn't exist; clamp to the
            # last valid day of that month, same failure mode Python's
            # datetime hits and JS Date silently rolls forward from.
            import calendar

            last_day = calendar.monthrange(year, month)[1]
            doc["warrantyExpiry"] = purchase_date.replace(year=year, month=month, day=last_day)
    else:
        doc["warrantyExpiry"] = None


# @route   GET /api/v1/assets?search=&category=
@router.get("")
async def list_assets(search: str | None = None, category: str | None = None, user: CurrentUser = Depends(get_current_user)):
    query: dict = {"user": ObjectId(user.id)}
    if category:
        query["category"] = re.compile(f"^{re.escape(category)}$", re.IGNORECASE)
    if search:
        term = re.compile(re.escape(search), re.IGNORECASE)
        query["$or"] = [{"name": term}, {"brand": term}, {"modelNumber": term}]

    assets = await database.db.assets.find(query).sort("createdAt", -1).to_list(length=None)
    return [serialize_asset(a) for a in assets]


# @route   GET /api/v1/assets/:id
@router.get("/{asset_id}")
async def get_asset(asset_id: str, user: CurrentUser = Depends(get_current_user)):
    asset = await load_owned("assets", to_object_id(asset_id), user, "Asset not found")
    return serialize_asset(asset)


# @route   POST /api/v1/assets
@router.post("", status_code=201)
async def create_asset(body: AssetBody, user: CurrentUser = Depends(get_current_user)):
    if not body.name or not body.name.strip():
        raise HTTPException(status_code=422, detail="Name is required")

    now = datetime.now(timezone.utc)
    doc = body.to_update_dict()
    doc.setdefault("category", "Other")
    doc.setdefault("warrantyDurationMonths", 0)
    doc.setdefault("reminderEnabled", False)
    doc["user"] = ObjectId(user.id)
    doc["createdAt"] = now
    doc["updatedAt"] = now
    _compute_warranty_expiry(doc)

    result = await database.db.assets.insert_one(doc)
    doc["_id"] = result.inserted_id
    return {"message": "Asset created", "asset": serialize_asset(doc)}


# @route   PUT /api/v1/assets/:id
@router.put("/{asset_id}")
async def update_asset(asset_id: str, body: AssetBody, user: CurrentUser = Depends(get_current_user)):
    asset = await load_owned("assets", to_object_id(asset_id), user, "Asset not found")

    updates = body.to_update_dict()
    asset.update(updates)
    asset["updatedAt"] = datetime.now(timezone.utc)
    _compute_warranty_expiry(asset)

    await database.db.assets.update_one({"_id": asset["_id"]}, {"$set": asset})
    return {"message": "Asset updated", "asset": serialize_asset(asset)}


# @route   DELETE /api/v1/assets/:id
# @desc    Cascades: deletes every document attached to this asset (records
#          + files on disk) so a deleted asset never leaves orphans behind.
@router.delete("/{asset_id}")
async def delete_asset(asset_id: str, user: CurrentUser = Depends(get_current_user)):
    asset = await load_owned("assets", to_object_id(asset_id), user, "Asset not found")

    async for doc in database.db.documents.find({"asset": asset["_id"]}):
        await delete_file_for_doc(doc)
    await database.db.documents.delete_many({"asset": asset["_id"]})

    await database.db.assets.delete_one({"_id": asset["_id"]})
    return {"message": "Asset deleted", "id": asset_id}
