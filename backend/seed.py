"""Adds sample products to an EXISTING account (never wipes anything).
Sign up in the app first, then run:  python seed.py you@example.com
Accounts themselves live in Firebase -- there are no demo passwords."""
import asyncio
import sys
from datetime import datetime, timezone

from app import database
from app.routers.assets import _compute_warranty_expiry


def months_ago(n: int) -> datetime:
    d = datetime.now(timezone.utc)
    month_index = d.month - 1 - n
    year = d.year + month_index // 12
    month = month_index % 12 + 1
    return d.replace(year=year, month=month)


async def run(email: str):
    await database.connect_db()
    db = database.db

    user = await db.users.find_one({"email": email.lower()})
    if not user:
        print(f"No user with email {email}. Sign up in the app (and make one authenticated request) first.")
        database.close_db()
        sys.exit(1)
    user_id = user["_id"]
    now = datetime.now(timezone.utc)

    assets = [
        {
            "user": user_id,
            "name": "iPhone 15",
            "category": "Phone",
            "brand": "Apple",
            "modelNumber": "A3092",
            "price": 79900,
            "purchaseDate": months_ago(2),
            "warrantyDurationMonths": 12,
            "reminderEnabled": True,
            "createdAt": now,
            "updatedAt": now,
        },
        {
            "user": user_id,
            "name": "MacBook Air M2",
            "category": "Laptop",
            "brand": "Apple",
            "modelNumber": "A2681",
            "price": 114900,
            "purchaseDate": months_ago(11),
            "warrantyDurationMonths": 12,  # expires soon
            "reminderEnabled": True,
            "createdAt": now,
            "updatedAt": now,
        },
        {
            "user": user_id,
            "name": "Samsung Refrigerator",
            "category": "Appliance",
            "brand": "Samsung",
            "price": 45000,
            "purchaseDate": months_ago(30),
            "warrantyDurationMonths": 24,  # already expired
            "reminderEnabled": False,
            "createdAt": now,
            "updatedAt": now,
        },
        {
            "user": user_id,
            "name": "Office Chair",
            "category": "Furniture",
            "brand": "IKEA",
            "price": 8500,
            "purchaseDate": months_ago(1),
            "warrantyDurationMonths": 0,
            "notes": "Assembled by service technician",
            "reminderEnabled": False,
            "createdAt": now,
            "updatedAt": now,
        },
    ]
    for asset in assets:
        _compute_warranty_expiry(asset)
        await db.assets.insert_one(asset)

    print(f"Added {len(assets)} sample products to {email}.")
    database.close_db()


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python seed.py <email-of-existing-user>")
        sys.exit(2)
    asyncio.run(run(sys.argv[1]))
