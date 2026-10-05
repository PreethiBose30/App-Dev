from datetime import datetime, timedelta, timezone

from bson import ObjectId
from fastapi import APIRouter, Depends

from .. import database
from ..dependencies import CurrentUser, get_current_user, require_role

router = APIRouter(prefix="/api/v1", tags=["dashboard"])


# @route   GET /api/v1/dashboard/stats
# @desc    Current user's vault statistics. There is no shared stock/
#          quantity concept in this app (each item is a personally-owned
#          document/asset, not shelf inventory), so "low stock"/"out of
#          stock" from a generic inventory spec don't apply here --
#          warranty status is the equivalent signal, so stats are built
#          around that instead.
@router.get("/dashboard/stats")
async def get_my_stats(user: CurrentUser = Depends(get_current_user)):
    user_oid = ObjectId(user.id)
    now = datetime.now(timezone.utc)
    in_30_days = now + timedelta(days=30)
    # A *missing* warrantyExpiry field is not treated as equal to null by
    # aggregation $ne/$eq (confirmed empirically against real MongoDB --
    # $type reports "missing", a distinct BSON type from null), so a bare
    # $lt would wrongly count every "no warranty tracked" item as expired.
    # $ifNull normalizes missing to null first so this guard actually
    # catches it. Ported as-is from the Node version, where this exact bug
    # was found and fixed.
    has_warranty_expiry = {"$ne": [{"$ifNull": ["$warrantyExpiry", None]}, None]}

    totals_cursor = database.db.assets.aggregate(
        [
            {"$match": {"user": user_oid}},
            {
                "$group": {
                    "_id": None,
                    "totalProducts": {"$sum": 1},
                    "totalValue": {"$sum": {"$ifNull": ["$price", 0]}},
                    "expiringSoon": {
                        "$sum": {
                            "$cond": [
                                {
                                    "$and": [
                                        has_warranty_expiry,
                                        {"$gte": ["$warrantyExpiry", now]},
                                        {"$lte": ["$warrantyExpiry", in_30_days]},
                                    ]
                                },
                                1,
                                0,
                            ]
                        }
                    },
                    "expired": {
                        "$sum": {"$cond": [{"$and": [has_warranty_expiry, {"$lt": ["$warrantyExpiry", now]}]}, 1, 0]}
                    },
                }
            },
        ]
    )
    by_category_cursor = database.db.assets.aggregate(
        [
            {"$match": {"user": user_oid}},
            {"$group": {"_id": "$category", "count": {"$sum": 1}}},
            {"$sort": {"count": -1}},
        ]
    )

    totals = await totals_cursor.to_list(length=1)
    by_category = await by_category_cursor.to_list(length=None)

    summary = totals[0] if totals else {"totalProducts": 0, "totalValue": 0, "expiringSoon": 0, "expired": 0}

    return {
        "totalProducts": summary["totalProducts"],
        "totalValue": summary["totalValue"],
        "expiringSoon": summary["expiringSoon"],
        "expired": summary["expired"],
        "byCategory": [{"category": c["_id"], "count": c["count"]} for c in by_category],
    }


# @route   GET /api/v1/admin/stats
# @desc    ADMIN ONLY: system-wide metrics. Deliberately aggregate-only --
#          admin does not get read access to any individual user's vault
#          contents (see dependencies.load_owned).
@router.get("/admin/stats")
async def get_admin_stats(user: CurrentUser = Depends(require_role("admin"))):
    total_users = await database.db.users.count_documents({})
    # Counts the Document collection, not Asset -- the Node version this
    # was ported from had this field still counting assets, a naming
    # leftover from before documents became their own collection.
    total_vaulted_documents = await database.db.documents.count_documents({})

    return {
        "systemStatus": "Optimal",
        "totalUsers": total_users,
        "totalVaultedDocuments": total_vaulted_documents,
        "accessRole": user.role,
    }
