import os
from pathlib import Path
from dotenv import load_dotenv

# Resolve .env relative to this package, not the process's cwd, so
# `uvicorn app.main:app` works the same whether it's launched from the
# repo root or from inside backend_python/.
load_dotenv(Path(__file__).resolve().parent.parent / ".env")

MONGO_URI = os.getenv("MONGO_URI", "")
JWT_SECRET = os.getenv("JWT_SECRET", "dev-only-secret-change-me")
JWT_EXPIRES_DAYS = int(os.getenv("JWT_EXPIRES_DAYS", "30"))
PORT = int(os.getenv("PORT", "5000"))
FRONTEND_URL = os.getenv("FRONTEND_URL", "")

UPLOAD_ROOT = Path(__file__).resolve().parent.parent / "uploads"
UPLOAD_ROOT.mkdir(exist_ok=True)

MAX_UPLOAD_SIZE = 10 * 1024 * 1024  # 10MB
ALLOWED_UPLOAD_TYPES = {
    "image/jpeg": ".jpg",
    "image/png": ".png",
    "application/pdf": ".pdf",
}
