FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

WORKDIR /usr/src/app

# Dependencies first, in their own layer: rebuilds after a code-only change
# reuse this cached layer instead of reinstalling everything.
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Run as an unprivileged user, not root.
RUN useradd --create-home --uid 1000 appuser

COPY --chown=appuser:appuser . .

# Created and owned by appuser in the image so a named volume mounted here
# inherits that ownership on first use (otherwise uploads would fail with a
# permission error under the non-root user).
RUN mkdir -p uploads && chown appuser:appuser uploads

USER appuser

EXPOSE 5000

# python (not curl) because the slim image has no curl.
HEALTHCHECK --interval=15s --timeout=5s --start-period=20s --retries=5 \
  CMD python -c "import sys, urllib.request; sys.exit(0 if urllib.request.urlopen('http://localhost:5000/api/health', timeout=4).status == 200 else 1)"

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "5000"]
