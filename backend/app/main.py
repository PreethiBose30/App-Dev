from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException, Request
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded

from . import config, database
from .limiter import limiter
from .routers import assets, auth, dashboard, documents


@asynccontextmanager
async def lifespan(app: FastAPI):
    await database.connect_db()
    yield
    database.close_db()


app = FastAPI(title="Digital Vault API", lifespan=lifespan)

app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

app.add_middleware(
    CORSMiddleware,
    allow_origins=config.FRONTEND_URL.split(",") if config.FRONTEND_URL else ["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.middleware("http")
async def security_headers(request: Request, call_next):
    # A lightweight stand-in for the Node backend's `helmet` middleware --
    # the handful of headers that actually matter for a JSON API (no
    # inline-script/CSP concerns here, there's no HTML being served).
    response = await call_next(request)
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-Frame-Options"] = "SAMEORIGIN"
    response.headers["X-XSS-Protection"] = "0"
    return response


# Centralized error handling: every response body is `{"message": "..."}`,
# matching the Node backend's shape (FastAPI's own default is
# `{"detail": "..."}`), and no stack trace ever reaches the client.
@app.exception_handler(HTTPException)
async def http_exception_handler(request: Request, exc: HTTPException):
    return JSONResponse(status_code=exc.status_code, content={"message": exc.detail})


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    return JSONResponse(status_code=422, content={"message": "Validation failed", "errors": exc.errors()})


@app.exception_handler(Exception)
async def unhandled_exception_handler(request: Request, exc: Exception):
    print(f"Unhandled error: {exc!r}")
    return JSONResponse(status_code=500, content={"message": "Internal Server Error"})


@app.get("/api/health")
async def health():
    return {"status": "Vault Backend Operational"}


app.include_router(auth.router)
app.include_router(assets.router)
app.include_router(documents.router)
app.include_router(dashboard.router)


@app.exception_handler(404)
async def not_found_handler(request: Request, exc):
    return JSONResponse(status_code=404, content={"message": f"Route not found: {request.method} {request.url.path}"})


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("app.main:app", host="0.0.0.0", port=config.PORT, reload=False)
