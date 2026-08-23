# Digital Vault API

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
| POST | `/auth/register` | none | `{ name, email, password }` | `role` always defaults to `user`; cannot self-assign `admin`. Rate-limited. |
| POST | `/auth/login` | none | `{ email, password }` | Returns `{ token, user }`. Rate-limited. |
| GET | `/auth/me` | Bearer | — | Returns the current user (no password). |

## Assets (the user's vaulted items)

| Method | Endpoint | Auth | Role | Body / Query |
|---|---|---|---|---|
| GET | `/assets?search=&category=` | Bearer | owner only | optional `search` (matches name/brand/model), `category` |
| GET | `/assets/:id` | Bearer | owner only | — |
| POST | `/assets` | Bearer | any user | `{ name*, category, brand, modelNumber, price, purchaseDate, warrantyDurationMonths, serviceDate, notes, reminderEnabled }` (`*` required) |
| PUT | `/assets/:id` | Bearer | owner only | any subset of the same fields |
| DELETE | `/assets/:id` | Bearer | owner only | also deletes the asset's stored document, if any |

`warrantyExpiry` is computed server-side from `purchaseDate` + `warrantyDurationMonths` and returned on every asset; it is not client-settable.

### Document (scanned bill / warranty card)

| Method | Endpoint | Auth | Role | Notes |
|---|---|---|---|---|
| POST | `/assets/:id/document` | Bearer | owner only | `multipart/form-data`, field name `document`. JPEG/PNG/PDF only, max 10MB. Replaces any existing document for that asset. |
| GET | `/assets/:id/document` | Bearer | owner only | Streams the file back with its original `Content-Type`. 404 if none uploaded. |
| DELETE | `/assets/:id/document` | Bearer | owner only | Deletes the file and clears `imagePath`/`documentOriginalName`/`documentMimeType` on the asset. |

Files are stored on disk under `backend/uploads/<userId>/<assetId>.<ext>` (one document per asset — a re-upload overwrites the previous file). `imagePath` on an asset is the server-generated filename, not a client-supplied path; it can only be set by uploading through this endpoint, never via the create/update body.

## Dashboard

| Method | Endpoint | Auth | Role | Response |
|---|---|---|---|---|
| GET | `/dashboard/stats` | Bearer | any user | `{ totalProducts, totalValue, expiringSoon, expired, byCategory: [{category, count}] }` for the current user only |
| GET | `/admin/stats` | Bearer | `admin` | `{ systemStatus, totalUsers, totalVaultedDocuments, accessRole }` — system-wide, no per-user data |

`expiringSoon` = items whose warranty expires within the next 30 days. `expired` = items whose warranty date has already passed. There is no shared stock/quantity concept in this app (each item is personally owned, not shelf inventory), so there's no `lowStockItems`/`outOfStockItems` — warranty status is the equivalent signal here.

## Error format

```json
{ "message": "human readable message" }
```
Validation failures (422) additionally include `"errors": [...]` from express-validator.

| Status | Meaning |
|---|---|
| 400 | Malformed request (e.g. invalid ObjectId) |
| 401 | Missing/invalid credentials, or missing JWT |
| 403 | Valid JWT but insufficient role, or accessing another user's asset |
| 404 | Resource / route not found |
| 409 | Duplicate (e.g. email already registered) |
| 422 | Request body failed validation |
| 500 | Unexpected server error (no stack trace is ever returned to the client) |

## Known limitations

- Document storage is local disk (`backend/uploads/`), not cloud object storage (S3/Cloudinary etc.) — fine for a single-instance deployment, but won't survive a stateless/multi-instance production setup without adding that later. Docker Compose mounts it as a named volume so it survives container restarts.
- OCR (Google ML Kit) runs entirely on-device in Flutter; extracted text is not sent to or stored by the backend.
