"""Development seed data. Run with: python seed.py
Wipes and repopulates users + assets with demo accounts and sample items."""
import asyncio
from datetime import datetime, timedelta, timezone

from app import database, security
from app.routers.assets import _compute_warranty_expiry


def months_ago(n: int) -> datetime:
    d = datetime.now(timezone.utc)
    month_index = d.month - 1 - n
    year = d.year + month_index // 12
    month = month_index % 12 + 1
    return d.replace(year=year, month=month)


async def run():
    await database.connect_db()
    db = database.db

    await db.users.delete_many({})
    await db.assets.delete_many({})
    await db.documents.delete_many({})

    now = datetime.now(timezone.utc)

    admin_result = await db.users.insert_one(
        {
            "name": "Admin Demo",
            "email": "admin@digitalvault.dev",
            "password": security.hash_password("Admin@123"),
            "role": "admin",
            "createdAt": now,
        }
    )
    user_result = await db.users.insert_one(
        {
            "name": "Preethi Demo",
            "email": "user@digitalvault.dev",
            "password": security.hash_password("User@123"),
            "role": "user",
            "createdAt": now,
        }
    )
    user_id = user_result.inserted_id

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
    # insert_one (not insert_many) with the computation applied here so
    # each asset gets the exact same warrantyExpiry logic the real POST
    # /assets route uses -- insert_many bypassed that entirely on the
    # first pass, silently leaving every seeded asset without one.
    for asset in assets:
        _compute_warranty_expiry(asset)
        await db.assets.insert_one(asset)

    print("Seed complete.")
    print("Demo credentials:")
    print("  admin: admin@digitalvault.dev / Admin@123")
    print("  user:  user@digitalvault.dev / User@123")
    database.close_db()


if __name__ == "__main__":
    asyncio.run(run())
