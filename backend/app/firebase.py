"""Firebase Admin SDK setup. The backend never signs anyone in: the phone
signs in with Firebase and sends the resulting ID token with every request;
this module only VERIFIES that token (signature, expiry, project) using
Google's public keys.

Credentials: a service-account JSON key, path from FIREBASE_CREDENTIALS
(relative paths resolve against backend/). The key is a secret -- it is
gitignored and dockerignored, and in Docker it is mounted as a secret, never
copied into the image.
"""
from pathlib import Path

import firebase_admin
from firebase_admin import auth as fb_auth
from firebase_admin import credentials
from starlette.concurrency import run_in_threadpool

from . import config

_app = None


def init_firebase() -> None:
    global _app
    if _app is not None:
        return
    path = Path(config.FIREBASE_CREDENTIALS)
    if not path.is_absolute():
        path = Path(__file__).resolve().parent.parent / path
    if not path.is_file():
        raise RuntimeError(
            f"Firebase service-account key not found at {path}. In the Firebase "
            "console: Project settings -> Service accounts -> Generate new "
            "private key, and save it as backend/firebase-service-account.json "
            "(or set FIREBASE_CREDENTIALS)."
        )
    _app = firebase_admin.initialize_app(credentials.Certificate(str(path)))


async def verify_id_token(token: str) -> dict:
    """Returns the decoded token claims, or raises ValueError (invalid or
    expired) -- the Admin SDK's verify call does blocking network I/O the
    first time it fetches Google's signing keys, so it runs in a thread."""
    try:
        return await run_in_threadpool(fb_auth.verify_id_token, token)
    except (fb_auth.InvalidIdTokenError, fb_auth.ExpiredIdTokenError, fb_auth.RevokedIdTokenError) as err:
        raise ValueError(str(err)) from err
    except ValueError:
        raise
    except Exception as err:  # noqa: BLE001 -- e.g. certificate fetch failure: treat as unverifiable, never as valid
        raise ValueError(f"Could not verify token: {err}") from err
