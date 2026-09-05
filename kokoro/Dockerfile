FROM ghcr.io/remsky/kokoro-fastapi-cpu
USER root
RUN pip install --no-cache-dir uv
COPY --chmod=755 kokoro/scripts/entrypoint.sh /entrypoint.sh
USER  appuser
ENTRYPOINT ["/entrypoint.sh"]

