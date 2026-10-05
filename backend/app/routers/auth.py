from bson import ObjectId
from fastapi import APIRouter, Depends, HTTPException
from pymongo import ReturnDocument

from .. import database
from ..dependencies import CurrentUser, get_current_user
from ..models.auth import UpdateProfileRequest
from ..utils import serialize_user

# Sign-up, sign-in, password hashing and password reset all live in Firebase
# Authentication now -- the app talks to Firebase for those and sends the ID
# token it gets back. Only profile endpoints remain here.
router = APIRouter(prefix="/api/v1/auth", tags=["auth"])


# @route   GET /api/v1/auth/me
# @desc    First call after sign-in. get_current_user creates the user's
#          MongoDB record if this is their first request.
@router.get("/me")
async def me(current: CurrentUser = Depends(get_current_user)):
    user = await database.db.users.find_one({"_id": ObjectId(current.id)})
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return serialize_user(user)


# @route   PUT /api/v1/auth/me
# @desc    Updates the current user's own name. Role is never accepted here
#          -- there's no self-service way to change it.
@router.put("/me")
async def update_me(body: UpdateProfileRequest, current: CurrentUser = Depends(get_current_user)):
    result = await database.db.users.find_one_and_update(
        {"_id": ObjectId(current.id)},
        {"$set": {"name": body.name}},
        return_document=ReturnDocument.AFTER,
    )
    if not result:
        raise HTTPException(status_code=404, detail="User not found")
    return serialize_user(result)
