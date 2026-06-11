#!/bin/bash
set -e

PORT=${KOKORO_PORT:-8880}
LOG_LEVEL=${KOKORO_LOG_LEVEL:-info}
DEVICE=${KOKORO_DEVICE:-cpu}

echo ">>> Starting Kokoro-FastAPI (device=${DEVICE}, port=${PORT}, log-level=${LOG_LEVEL})..."

exec uv run --extra "${DEVICE}" --no-sync python -m uvicorn api.src.main:app \
  --host 0.0.0.0 \
  --port "${PORT}" \
  --log-level "${LOG_LEVEL}"
