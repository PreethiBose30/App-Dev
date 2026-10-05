"""Entry point for local dev tooling (see ../.claude/launch.json). Inserts
this file's own directory onto sys.path first, so `python run.py` finds the
`app` package regardless of the process's working directory -- unlike
`python -m uvicorn app.main:app`, which requires cwd to already be
backend/.
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import uvicorn  # noqa: E402

from app.config import PORT  # noqa: E402

if __name__ == "__main__":
    uvicorn.run("app.main:app", host="0.0.0.0", port=PORT, reload=False)
