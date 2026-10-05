from bson import ObjectId


def oid_str(value) -> str | None:
    return str(value) if value is not None else None


def serialize_user(user: dict) -> dict:
    return {
        "id": oid_str(user["_id"]),
        "name": user["name"],
        "email": user["email"],
        "role": user["role"],
    }


def serialize_asset(asset: dict) -> dict:
    out = {
        "_id": oid_str(asset["_id"]),
        "user": oid_str(asset["user"]),
        "name": asset["name"],
        "category": asset["category"],
        "reminderEnabled": asset.get("reminderEnabled", False),
        "warrantyDurationMonths": asset.get("warrantyDurationMonths", 0),
        "createdAt": asset.get("createdAt"),
        "updatedAt": asset.get("updatedAt"),
    }
    for field in ("brand", "modelNumber", "price", "purchaseDate", "warrantyExpiry", "serviceDate", "notes"):
        if asset.get(field) is not None:
            out[field] = asset[field]
    return out


def serialize_document(doc: dict) -> dict:
    return {
        "_id": oid_str(doc["_id"]),
        "asset": oid_str(doc["asset"]),
        "user": oid_str(doc["user"]),
        "localId": doc["localId"],
        "filename": doc["filename"],
        "mimeType": doc["mimeType"],
        "size": doc["size"],
        "checksum": doc.get("checksum", ""),
        "createdAt": doc.get("createdAt"),
        "updatedAt": doc.get("updatedAt"),
    }


def to_object_id(value: str, field_name: str = "id"):
    if not ObjectId.is_valid(value):
        from fastapi import HTTPException

        raise HTTPException(status_code=400, detail="Invalid ID format")
    return ObjectId(value)
