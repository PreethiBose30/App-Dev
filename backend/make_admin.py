"""Grants or removes the admin role. Admin is a Firebase custom claim
(`admin: true`) set here with the service-account key, so it lives inside the
signed ID token and a client cannot grant it to itself.

    python make_admin.py you@example.com            # make admin
    python make_admin.py you@example.com --remove   # back to normal user

The person must sign out and back in (or wait up to an hour) before their
token carries the new claim.
"""
import sys

from firebase_admin import auth

from app import firebase


def main() -> int:
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    remove = "--remove" in sys.argv
    if len(args) != 1:
        print(__doc__)
        return 2
    firebase.init_firebase()
    try:
        user = auth.get_user_by_email(args[0])
    except auth.UserNotFoundError:
        print(f"No Firebase user with email {args[0]}. They must sign up in the app first.")
        return 1
    claims = dict(user.custom_claims or {})
    if remove:
        claims.pop("admin", None)
    else:
        claims["admin"] = True
    auth.set_custom_user_claims(user.uid, claims or None)
    print(f"{args[0]} is now {'a normal user' if remove else 'an admin'}. They must sign in again for it to take effect.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
