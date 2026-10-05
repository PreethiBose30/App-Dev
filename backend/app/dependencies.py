import jwt
from bson import ObjectId
from fastapi import Depends, HTTPException
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from . import database, security

_bearer = HTTPBearer(auto_error=False)


class CurrentUser:
    def __init__(self, id: str, role: str):
        self.id = id
        self.role = role


async def get_current_user(credentials: HTTPAuthorizationCredentials | None = Depends(_bearer)) -> CurrentUser:
    if credentials is None:
        raise HTTPException(status_code=401, detail="Access token required")
    try:
        payload = security.decode_token(credentials.credentials)
    except jwt.PyJWTError:
        raise HTTPException(status_code=403, detail="Invalid or expired token")
    return CurrentUser(id=payload["id"], role=payload["role"])


def require_role(*roles: str):
    async def _check(user: CurrentUser = Depends(get_current_user)) -> CurrentUser:
        if user.role not in roles:
            raise HTTPException(status_code=403, detail="Access denied: insufficient permissions")
        return user

    return _check


async def load_owned(collection_name: str, doc_id: ObjectId, user: CurrentUser, not_found_message: str) -> dict:
    """Every resource in this app is privately owned by exactly one user (a
    personal vault, not a shared team inventory). This is the one place
    that rule is enforced, mirroring backend/src/utils/ownership.js from
    the Node version this was ported from.
    """
    doc = await database.db[collection_name].find_one({"_id": doc_id})
    if doc is None:
        raise HTTPException(status_code=404, detail=not_found_message)
    if str(doc["user"]) != user.id:
        raise HTTPException(status_code=403, detail="Access denied: you do not own this item")
    return doc
