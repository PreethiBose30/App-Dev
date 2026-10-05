# Digital Vault API

Stack: **FastAPI + Motor (async MongoDB driver)**. Ported from an earlier Node/Express version — the API contract below is unchanged, so the Flutter app needed zero changes for that migration. Sign-in has since moved to Firebase Authentication (see Auth).

Base URL: `http://localhost:5000/api/v1` (health check lives at `/api/health`, outside `v1`).

All request/response bodies are JSON. Protected routes require:

```
Authorization: Bearer <Firebase ID token>
```

Domain note: this is a **personal** vault, not a shared team inventory. Every
asset belongs to exactly one user; nobody (including `admin`) can read or
modify another user's items. `admin` only unlocks aggregate, anonymous
system stats (`/admin/stats`).

## Auth

Sign-up, sign-in, passwords and password reset are handled by **Firebase Authentication**, not by this API. The app signs in with Firebase and sends the resulting **ID token** as the Bearer token on every request (the Firebase SDK refreshes it hourly). The API verifies the token's signature, expiry and project with the Firebase Admin SDK.

On a person's first authenticated request the API creates their MongoDB user record (name from the token, email lowercased, matched by Firebase uid). That record's id owns all of their products and documents.

| Method | Endpoint | Auth | Body | Notes |
|---|---|---|---|---|
| GET | `/auth/me` | Bearer | � | Returns `{ id, name, email, role }`; creates the record on first call. |
| PUT | `/auth/me` | Bearer | `{ name }` | Updates your own name. Role can never be changed here. |

**Admin role.** `role` is `admin` only if the Firebase token carries the custom claim `admin: true`. That claim can only be set with the service-account key:

```bash
python make_admin.py you@example.com            # grant
python make_admin.py you@example.com --remove   # revoke
```

The person must sign out and in again (or wait up to an hour) for the claim to appear in their token.

## Assets (the user's vaulted items)

| Method | Endpoint | Auth | Role | Body / Query |
|---|---|---|---|---|
| GET | `/assets?search=&category=` | Bearer | owner only | optional `search` (matches name/brand/model), `category` |
| GET | `/assets/:id` | Bearer | owner only | — |
| POST | `/assets` | Bearer | any user | `{ name*, category, brand, modelNumber, price, purchaseDate, warrantyDurationMonths, serviceDate, notes, reminderEnabled }` (`*` required) |
| PUT | `/assets/:id` | Bearer | owner only | any subset of the same fields |
| DELETE | `/assets/:id` | Bearer | owner only | cascades: deletes every document attached to this asset (records + files) |

`warrantyExpiry` is computed server-side from `purchaseDate` + `warrantyDurationMonths` and returned on every asset; it is not client-settable.

## Documents (scanned bills, warranty cards, etc.)

An asset can have **any number** of documents attached (a receipt, a warranty card, an insurance paper, ...). Each is its own record with its own id.

| Method | Endpoint | Auth | Role | Notes |
|---|---|---|---|---|
| GET | `/assets/:assetId/documents` | Bearer | owner only | List all documents for one asset |
| POST | `/assets/:assetId/documents` | Bearer | owner only | `multipart/form-data`: `document` (file, JPEG/PNG/PDF, max 10MB), `localId` (required), `checksum` (optional, SHA-256 hex) |
| GET | `/documents/:id` | Bearer | owner only | Metadata only |
| GET | `/documents/:id/download` | Bearer | owner only | Streams the file with its original `Content-Type` |
| DELETE | `/documents/:id` | Bearer | owner only | Deletes the record and the file on disk |

### Idempotent upload (no duplicate documents on retry)

`localId` is a client-generated id (a UUID from the phone's local Hive record, not a Mongo ObjectId) that uniquely identifies *this capture* for *this user*, enforced by a unique `(user, localId)` index on the `documents` collection (created at startup — see `app/database.py`). Practical effect:

- First upload with a given `localId` → creates the document, `201`.
- Any later upload with the **same** `localId` (a retry after a network failure hid the success response, or two near-simultaneous retries racing each other) → the existing document is returned unchanged, `200`, and the newly-uploaded file is discarded. No duplicate is ever created, no matter how many times the client retries. The race case is handled explicitly: if two requests both pass the pre-check and race to insert, MongoDB's unique index lets only one through and the loser's `DuplicateKeyError` is caught and turned into the same "already synced" response.

This is what lets the Flutter app capture a document offline, save it locally, and safely retry the upload as many times as it needs to once connectivity returns.

Files are stored on disk under `backend/uploads/<userId>/<randomly-generated-name>.<ext>` -- the on-disk name is unrelated to `localId` or the original filename (recorded separately as `storedFilename` on the document, an internal detail the API never exposes).

## Dashboard

| Method | Endpoint | Auth | Role | Response |
|---|---|---|---|---|
| GET | `/dashboard/stats` | Bearer | any user | `{ totalProducts, totalValue, expiringSoon, expired, byCategory: [{category, count}] }` for the current user only |
| GET | `/admin/stats` | Bearer | `admin` | `{ systemStatus, totalUsers, totalVaultedDocuments, accessRole }` — system-wide, no per-user data. `totalVaultedDocuments` counts the `documents` collection. |

`expiringSoon` = items whose warranty expires within the next 30 days. `expired` = items whose warranty date has already passed. There is no shared stock/quantity concept in this app (each item is personally owned, not shelf inventory), so there's no `lowStockItems`/`outOfStockItems` — warranty status is the equivalent signal here.

A missing `warrantyExpiry` is guarded against explicitly in the aggregation (`$ifNull` before the null-check) — MongoDB's aggregation `$ne`/`$eq` do not treat a genuinely *missing* field as equal to `null` (confirmed empirically), so a naive query would wrongly count every item with no warranty tracked as "expired".

## Error format

```json
{ "message": "human readable message" }
```
Validation failures (422) additionally include `"errors": [...]` (FastAPI's Pydantic validation error list).

| Status | Meaning |
|---|---|
| 400 | Malformed request (e.g. invalid ObjectId, wrong file type) |
| 401 | Missing, invalid or expired Firebase token |
| 403 | Valid token but insufficient role, or accessing another user's asset/document |
| 404 | Resource / route not found |
| 409 | Duplicate |
| 422 | Request body failed validation |
| 500 | Unexpected server error (no stack trace is ever returned to the client) |

## Interactive docs

FastAPI auto-generates OpenAPI docs at `/docs` (Swagger UI) and `/redoc` while the server is running -- useful for exploring/testing the API by hand, something the Node version didn't have without adding a separate package.

## Known limitations

- Document storage is local disk (`backend/uploads/`), not cloud object storage (S3/Cloudinary etc.) — fine for a single-instance deployment, but won't survive a stateless/multi-instance production setup without adding that later. Docker Compose mounts it as a named volume so it survives container restarts.
- OCR (Google ML Kit) runs entirely on-device in Flutter; extracted text is not sent to or stored by the backend.

## Running with Docker

Requires Docker Desktop (Windows/Mac) or Docker Engine. Run everything from `backend/`.

```bash
# first time only
copy .env.example .env          # then set MONGO_URI if using Atlas
# and save your Firebase service-account key as backend/firebase-service-account.json

docker compose up -d --build    # build the image and start api + mongo
docker compose ps               # both should say (healthy)
docker compose logs -f api      # watch the API log (Ctrl+C stops watching, not the app)
docker compose down             # stop and remove containers, KEEP all data
```

- API: `http://localhost:5000` (docs at `/docs`, health at `/api/health`).
- **Which database?** If `backend/.env` sets `MONGO_URI` (e.g. Atlas), the API uses it and the `mongo` container sits unused. If it is empty, the API uses the `mongo` container. To force the local container for one run: `MONGO_URI=mongodb://mongo:27017/digital_vault docker compose up -d` (PowerShell: `$env:MONGO_URI="mongodb://mongo:27017/digital_vault"; docker compose up -d`).
- If `MONGO_URI` is set but wrong (bad password, Atlas network access), the API refuses to start and logs why. It never falls back to a throwaway database when one is configured.
- The Firebase key is mounted into the container as a Docker secret (`/run/secrets/firebase_key`), never copied into the image.
- MongoDB is deliberately **not** published to your PC (no port 27017). Only the `api` container can reach it.

### Where the data lives

| Data | Docker volume | Survives `restart` | Survives `down` + `up` | Survives rebuild |
| --- | --- | --- | --- | --- |
| Database (users, products, document records) | `backend_mongo-data` | yes | yes | yes |
| Uploaded document files | `backend_uploads-data` | yes | yes | yes |

Only `docker compose down -v` (note the `-v`) deletes the volumes, and with them all data. To reset on purpose: `docker compose down -v`.

### Tested

Build, start, health check, Firebase-token auth (auto-created user, ownership 403s, admin claim, 8 concurrent first requests -> one record), create a product, upload and download a PDF, `restart`, `down` + `up`, and rebuild with `--force-recreate` all kept the data. A retried upload with the same `localId` returned the original document, not a duplicate. The image contains no `.env` and no virtualenv, and runs as a non-root user.
