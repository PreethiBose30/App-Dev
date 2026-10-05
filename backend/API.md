# Digital Vault API

Stack: **FastAPI + Motor (async MongoDB driver)**. Ported from an earlier Node/Express version — the API contract below is unchanged, so the Flutter app needed zero changes for this migration.

Base URL: `http://localhost:5000/api/v1` (health check lives at `/api/health`, outside `v1`).

All request/response bodies are JSON. Protected routes require:

```
Authorization: Bearer <JWT>
```

Domain note: this is a **personal** vault, not a shared team inventory. Every
asset belongs to exactly one user; nobody (including `admin`) can read or
modify another user's items. `admin` only unlocks aggregate, anonymous
system stats (`/admin/stats`).

## Auth

| Method | Endpoint | Auth | Body | Notes |
|---|---|---|---|---|
| POST | `/auth/register` | none | `{ name, email, password }` | `role` always defaults to `user`; cannot self-assign `admin`. Rate-limited (30/15min per IP). |
| POST | `/auth/login` | none | `{ email, password }` | Returns `{ token, user }`. Rate-limited. |
| GET | `/auth/me` | Bearer | — | Returns the current user (no password). |

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

Files are stored on disk under `backend_python/uploads/<userId>/<randomly-generated-name>.<ext>` -- the on-disk name is unrelated to `localId` or the original filename (recorded separately as `storedFilename` on the document, an internal detail the API never exposes).

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
| 401 | Missing/invalid credentials, or missing JWT |
| 403 | Valid JWT but insufficient role, or accessing another user's asset/document |
| 404 | Resource / route not found |
| 409 | Duplicate (e.g. email already registered) |
| 422 | Request body failed validation |
| 429 | Rate limit exceeded (auth endpoints only) |
| 500 | Unexpected server error (no stack trace is ever returned to the client) |

## Interactive docs

FastAPI auto-generates OpenAPI docs at `/docs` (Swagger UI) and `/redoc` while the server is running -- useful for exploring/testing the API by hand, something the Node version didn't have without adding a separate package.

## Known limitations

- Document storage is local disk (`backend_python/uploads/`), not cloud object storage (S3/Cloudinary etc.) — fine for a single-instance deployment, but won't survive a stateless/multi-instance production setup without adding that later. Docker Compose mounts it as a named volume so it survives container restarts.
- OCR (Google ML Kit) runs entirely on-device in Flutter; extracted text is not sent to or stored by the backend.
