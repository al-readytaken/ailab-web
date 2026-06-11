#!/bin/sh
set -e

CERT_DIR=/data/certs
CERT_FILE=$CERT_DIR/cert.pem
KEY_FILE=$CERT_DIR/key.pem

if [ ! -f "$CERT_FILE" ] || [ ! -f "$KEY_FILE" ]; then
    mkdir -p "$CERT_DIR"
    openssl req -x509 -nodes -days "${CERT_DAYS:-3650}" -newkey rsa:2048 \
        -keyout "$KEY_FILE" -out "$CERT_FILE" \
        -subj "/CN=${CERT_CN:-openwebui.local}/O=${CERT_O:-AI Lab}/C=${CERT_C:-DE}"
    echo ">>> Self-signed certificate generated (CN=${CERT_CN:-openwebui.local}, ${CERT_DAYS:-3650} days)"
fi

echo ">>> Starting nginx..."
exec nginx -g "daemon off;"
