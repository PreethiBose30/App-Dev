from datetime import datetime, timedelta, timezone

import bcrypt
import jwt

from . import config


def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt(rounds=10)).decode()


def verify_password(password: str, hashed: str) -> bool:
    return bcrypt.checkpw(password.encode(), hashed.encode())


def generate_token(user_id: str, role: str) -> str:
    payload = {
        "id": user_id,
        "role": role,
        "iat": datetime.now(timezone.utc),
        "exp": datetime.now(timezone.utc) + timedelta(days=config.JWT_EXPIRES_DAYS),
    }
    return jwt.encode(payload, config.JWT_SECRET, algorithm="HS256")


def decode_token(token: str) -> dict:
    # Raises jwt.PyJWTError (caught in dependencies.py) on anything
    # invalid/expired -- same "invalid or expired token" outcome as the
    # Node backend's jwt.verify callback.
    return jwt.decode(token, config.JWT_SECRET, algorithms=["HS256"])
