from datetime import datetime, timezone

from bson import ObjectId
from fastapi import Depends, HTTPException
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from pymongo.errors import DuplicateKeyError

from . import database, firebase

_bearer = HTTPBearer(auto_error=False)


class CurrentUser:
    def __init__(self, id: str, role: str):
        self.id = id  # the MongoDB user _id (what every product/document is owned by)
        self.role = role


async def _get_or_create_user(claims: dict) -> dict:
    """Maps a verified Firebase identity to our MongoDB user record, creating
    it on that person's first request. Ownership of products and documents
    hangs off the MongoDB _id, so none of that logic cares that sign-in moved
    to Firebase.

    Role comes from the token's `admin` custom claim (set only by
    make_admin.py with the service-account key) -- a client cannot grant
    itself admin, because the claim is inside the signed token.
    """
    uid = claims["uid"]
    role = "admin" if claims.get("admin") is True else "user"
    users = database.db.users

    user = await users.find_one({"firebaseUid": uid})
    if user is None:
        email = claims.get("email")
        if not email:
            raise HTTPException(status_code=400, detail="This Firebase account has no email address")
        doc = {
            "firebaseUid": uid,
            "name": claims.get("name") or email.split("@")[0],
            "email": email.lower(),
            "role": role,
            "createdAt": datetime.now(timezone.utc),
        }
        try:
            result = await users.insert_one(doc)
            doc["_id"] = result.inserted_id
            return doc
        except DuplicateKeyError:
            # Two first requests raced; the unique firebaseUid index let one
            # through. Use the winner's record.
            return await users.find_one({"firebaseUid": uid})

    if user.get("role") != role:
        await users.update_one({"_id": user["_id"]}, {"$set": {"role": role}})
        user["role"] = role
    return user


async def get_current_user(credentials: HTTPAuthorizationCredentials | None = Depends(_bearer)) -> CurrentUser:
    if credentials is None:
        raise HTTPException(status_code=401, detail="Access token required")
    try:
        claims = await firebase.verify_id_token(credentials.credentials)
    except ValueError:
        raise HTTPException(status_code=401, detail="Invalid or expired token")
    user = await _get_or_create_user(claims)
    return CurrentUser(id=str(user["_id"]), role=user["role"])


def require_role(*roles: str):
    async def _check(user: CurrentUser = Depends(get_current_user)) -> CurrentUser:
        if user.role not in roles:
            raise HTTPException(status_code=403, detail="Access denied: insufficient permissions")
        return user

    return _check


async def load_owned(collection_name: str, doc_id: ObjectId, user: CurrentUser, not_found_message: str) -> dict:
    """Every resource in this app is privately owned by exactly one user (a
    personal vault, not a shared team inventory). This is the one place
    that rule is enforced.
    """
    doc = await database.db[collection_name].find_one({"_id": doc_id})
    if doc is None:
        raise HTTPException(status_code=404, detail=not_found_message)
    if str(doc["user"]) != user.id:
        raise HTTPException(status_code=403, detail="Access denied: you do not own this item")
    return doc
