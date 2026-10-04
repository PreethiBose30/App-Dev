import uuid
from datetime import datetime, timezone
from pathlib import Path

from bson import ObjectId
from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile
from fastapi.responses import FileResponse
from pymongo.errors import DuplicateKeyError

from .. import config, database
from ..dependencies import CurrentUser, get_current_user, load_owned
from ..utils import serialize_document, to_object_id

router = APIRouter(prefix="/api/v1", tags=["documents"])


def _disk_path(doc: dict) -> Path:
    return config.UPLOAD_ROOT / str(doc["user"]) / doc["storedFilename"]


async def delete_file_for_doc(doc: dict) -> None:
    path = _disk_path(doc)
    path.unlink(missing_ok=True)


# @route   POST /api/v1/assets/{assetId}/documents
# @desc    Idempotent on (user, localId): a retried upload (network failure
#          hid a successful response, or two near-simultaneous retries
#          racing each other) always returns the existing document instead
#          of creating a duplicate -- enforced by database.py's unique
#          index on (user, localId), not just this pre-check.
@router.post("/assets/{asset_id}/documents", status_code=201)
async def upload_document(
    asset_id: str,
    document: UploadFile = File(...),
    localId: str = Form(...),
    checksum: str = Form(""),
    user: CurrentUser = Depends(get_current_user),
):
    asset = await load_owned("assets", to_object_id(asset_id), user, "Asset not found")

    if document.content_type not in config.ALLOWED_UPLOAD_TYPES:
        raise HTTPException(status_code=400, detail="Only JPEG, PNG, or PDF files are allowed")

    existing = await database.db.documents.find_one({"user": ObjectId(user.id), "localId": localId})
    if existing:
        return {"message": "Document already synced", "document": serialize_document(existing)}

    body = await document.read()
    if len(body) > config.MAX_UPLOAD_SIZE:
        raise HTTPException(status_code=400, detail="File is too large (max 10MB)")

    ext = config.ALLOWED_UPLOAD_TYPES[document.content_type]
    stored_filename = f"{uuid.uuid4()}{ext}"
    user_dir = config.UPLOAD_ROOT / user.id
    user_dir.mkdir(parents=True, exist_ok=True)
    (user_dir / stored_filename).write_bytes(body)

    now = datetime.now(timezone.utc)
    doc = {
        "asset": asset["_id"],
        "user": ObjectId(user.id),
        "localId": localId,
        "filename": document.filename or stored_filename,
        "mimeType": document.content_type,
        "size": len(body),
        "checksum": checksum,
        "storedFilename": stored_filename,
        "createdAt": now,
        "updatedAt": now,
    }

    try:
        result = await database.db.documents.insert_one(doc)
        doc["_id"] = result.inserted_id
    except DuplicateKeyError:
        # Two near-simultaneous retries both passed the check above and
        # raced to insert -- the unique index let only one through. The
        # loser cleans up its now-orphaned file and returns the winner's
        # document, same as the pre-check path above.
        (user_dir / stored_filename).unlink(missing_ok=True)
        winner = await database.db.documents.find_one({"user": ObjectId(user.id), "localId": localId})
        return {"message": "Document already synced", "document": serialize_document(winner)}

    return {"message": "Document uploaded", "document": serialize_document(doc)}


# @route   GET /api/v1/assets/{assetId}/documents
@router.get("/assets/{asset_id}/documents")
async def list_documents(asset_id: str, user: CurrentUser = Depends(get_current_user)):
    await load_owned("assets", to_object_id(asset_id), user, "Asset not found")
    docs = await database.db.documents.find({"asset": ObjectId(asset_id), "user": ObjectId(user.id)}).sort("createdAt", -1).to_list(length=None)
    return [serialize_document(d) for d in docs]


# @route   GET /api/v1/documents/{id}
@router.get("/documents/{document_id}")
async def get_document(document_id: str, user: CurrentUser = Depends(get_current_user)):
    doc = await load_owned("documents", to_object_id(document_id), user, "Document not found")
    return serialize_document(doc)


# @route   GET /api/v1/documents/{id}/download
@router.get("/documents/{document_id}/download")
async def download_document(document_id: str, user: CurrentUser = Depends(get_current_user)):
    doc = await load_owned("documents", to_object_id(document_id), user, "Document not found")
    path = _disk_path(doc)
    if not path.exists():
        raise HTTPException(status_code=404, detail="Document file is missing on the server")
    return FileResponse(path, media_type=doc["mimeType"], filename=doc["filename"])


# @route   DELETE /api/v1/documents/{id}
@router.delete("/documents/{document_id}")
async def delete_document(document_id: str, user: CurrentUser = Depends(get_current_user)):
    doc = await load_owned("documents", to_object_id(document_id), user, "Document not found")
    await delete_file_for_doc(doc)
    await database.db.documents.delete_one({"_id": doc["_id"]})
    return {"message": "Document deleted", "id": document_id}
