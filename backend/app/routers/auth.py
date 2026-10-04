from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, Request

from .. import database, security
from ..dependencies import CurrentUser, get_current_user
from ..limiter import limiter
from ..models.auth import LoginRequest, RegisterRequest
from ..utils import serialize_user

router = APIRouter(prefix="/api/v1/auth", tags=["auth"])


# @route   POST /api/v1/auth/register
# @desc    role always defaults to "user"; cannot self-assign "admin".
@router.post("/register", status_code=201)
@limiter.limit("30/15minutes")
async def register(request: Request, body: RegisterRequest):
    existing = await database.db.users.find_one({"email": body.email})
    if existing:
        raise HTTPException(status_code=409, detail="A user with that email already exists")

    now = datetime.now(timezone.utc)
    doc = {
        "name": body.name,
        "email": body.email,
        "password": security.hash_password(body.password),
        "role": "user",
        "createdAt": now,
    }
    result = await database.db.users.insert_one(doc)
    doc["_id"] = result.inserted_id

    token = security.generate_token(str(doc["_id"]), doc["role"])
    return {"message": "Account created successfully", "token": token, "user": serialize_user(doc)}


# @route   POST /api/v1/auth/login
@router.post("/login")
@limiter.limit("30/15minutes")
async def login(request: Request, body: LoginRequest):
    user = await database.db.users.find_one({"email": body.email})
    if not user or not security.verify_password(body.password, user["password"]):
        raise HTTPException(status_code=401, detail="Invalid email or password")

    token = security.generate_token(str(user["_id"]), user["role"])
    return {"message": "Authorization successful", "token": token, "user": serialize_user(user)}


# @route   GET /api/v1/auth/me
@router.get("/me")
async def me(current: CurrentUser = Depends(get_current_user)):
    from bson import ObjectId

    user = await database.db.users.find_one({"_id": ObjectId(current.id)})
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return serialize_user(user)
