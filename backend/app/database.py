import shutil
import subprocess
import tempfile
import time
from pathlib import Path

from motor.motor_asyncio import AsyncIOMotorClient

from . import config

client: AsyncIOMotorClient | None = None
db = None
_fallback_process: subprocess.Popen | None = None

_FALLBACK_PORT = 27018


def _find_mongod() -> str | None:
    """Looks for a local mongod binary to run as a throwaway dev database
    when MONGO_URI isn't set. Checked in order: PATH, then the cache
    directory the mongodb-memory-server npm package (used by this
    project's Node backend) downloads a real mongod binary into -- if
    that's already been run once on this machine, this reuses the exact
    same binary instead of asking the developer to install MongoDB
    separately.
    """
    on_path = shutil.which("mongod")
    if on_path:
        return on_path

    cache_dir = Path.home() / ".cache" / "mongodb-binaries"
    if cache_dir.is_dir():
        candidates = sorted(cache_dir.glob("mongod*"), reverse=True)
        if candidates:
            return str(candidates[0])
    return None


async def _connect(uri: str) -> bool:
    global client, db
    try:
        # tz_aware=True: without it, Motor returns naive datetimes for BSON
        # dates -- fine for the freshly-created object still in memory
        # (built with datetime.now(timezone.utc), so still tz-aware), but
        # every date re-fetched from MongoDB afterwards would serialize
        # without a UTC marker at all, which Dart's DateTime.tryParse then
        # silently misreads as *local* time instead of UTC. Exactly the
        # class of date-shifting bug already found and fixed once in the
        # Node version of this backend -- this is the equivalent fix here.
        candidate = AsyncIOMotorClient(uri, serverSelectionTimeoutMS=5000, tz_aware=True)
        await candidate.admin.command("ping")
        client = candidate
        try:
            db = client.get_default_database()
        except Exception:  # noqa: BLE001 -- URI had no /<dbname> path segment
            db = client["digital_vault"]
        return True
    except Exception as err:  # noqa: BLE001 -- deliberately broad: any connection failure should fall through to the dev fallback below
        print(f"Could not connect: {err}")
        return False


async def connect_db() -> None:
    if config.MONGO_URI:
        if await _connect(config.MONGO_URI):
            print(f"MongoDB connected: {client.address}")
            await _ensure_indexes()
            return
        # A database address WAS configured but the connection failed (wrong
        # password, Atlas network access, server down). Never fall back to
        # the throwaway database here: that silently hides the real problem
        # and every account and product would vanish on the next restart.
        # Failing loudly is the only safe behaviour.
        raise RuntimeError(
            "MONGO_URI is set but the database could not be reached (see the "
            "'Could not connect' line above). Check the username and password "
            "in backend/.env, that Atlas Network Access allows your IP, and "
            "that the cluster is running. Not starting with a throwaway "
            "database, because your data would be lost on restart."
        )

    print("MONGO_URI not set.")
    print(
        "Falling back to a local throwaway MongoDB instance for development. "
        "Data will NOT persist between restarts -- set MONGO_URI in "
        "backend/.env to use a real database."
    )
    mongod_path = _find_mongod()
    if not mongod_path:
        raise RuntimeError(
            "No MONGO_URI set and no local mongod binary found. "
            "Set MONGO_URI in backend/.env (e.g. a MongoDB Atlas connection "
            "string), or install MongoDB locally."
        )

    global _fallback_process
    dbpath = tempfile.mkdtemp(prefix="digital_vault_mongo_")
    _fallback_process = subprocess.Popen(
        [mongod_path, "--dbpath", dbpath, "--port", str(_FALLBACK_PORT), "--bind_ip", "127.0.0.1", "--quiet"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )

    # Give it a moment to come up, then retry the connection a few times
    # rather than a single fixed sleep -- a slow machine on first launch
    # can take longer than a guessed delay.
    uri = f"mongodb://127.0.0.1:{_FALLBACK_PORT}/digital_vault"
    for attempt in range(20):
        time.sleep(0.5)
        if await _connect(uri):
            print(f"Connected to local throwaway MongoDB on port {_FALLBACK_PORT}")
            await _ensure_indexes()
            return

    raise RuntimeError("Started a local mongod but could not connect to it.")


async def _ensure_indexes() -> None:
    # Mirrors the Node backend's schema-level unique index: a (user,
    # localId) pair can only ever map to one document, which is what
    # actually guarantees a retried upload never creates a duplicate.
    await db.documents.create_index([("user", 1), ("localId", 1)], unique=True)
    # Identity is the Firebase uid now. Email is no longer unique here: the
    # old unique email index belonged to the self-run login system, and
    # Firebase already guarantees one account per email.
    try:
        await db.users.drop_index("email_1")
    except Exception:  # noqa: BLE001 -- index absent (fresh database) or already dropped
        pass
    await db.users.create_index("email")
    # Partial rather than sparse-unique: legacy users from the old login
    # system have no firebaseUid and must not collide with each other.
    await db.users.create_index(
        "firebaseUid",
        unique=True,
        partialFilterExpression={"firebaseUid": {"$type": "string"}},
    )


def close_db() -> None:
    if client:
        client.close()
    if _fallback_process:
        _fallback_process.terminate()
