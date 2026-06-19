#!/bin/bash
set -e

SITE_CONF=/config/nginx/site-confs/default.conf

# Deploy default nginx site config on first run
if [ ! -f "$SITE_CONF" ]; then
    mkdir -p "$(dirname "$SITE_CONF")"
    cp /default-site.conf "$SITE_CONF"
    echo ">>> Deployed default nginx site config"
fi

LE_LIVE_DIR="/config/etc/letsencrypt/live/${URL:-example.com}"

# Decide whether to use self-signed fallback or real Let's Encrypt certs.
# The init-certbot-config script always does:
#   rm -rf /config/keys/letsencrypt && ln -s ../etc/letsencrypt/live/${URL} /config/keys/letsencrypt
# Then checks /config/keys/letsencrypt/fullchain.pem (through symlink).
# If we seed certs at the target path first, the check succeeds and certbot is skipped.
USE_SELF_SIGNED=false
if [ "${STAGING,,}" = "true" ]; then
    USE_SELF_SIGNED=true
elif [ "${URL:-example.com}" = "example.com" ]; then
    echo "!!! WARNING: STAGING=false but URL is still the placeholder 'example.com'."
    echo "!!! Falling back to self-signed certificate. Set URL to your real domain for Let's Encrypt."
    USE_SELF_SIGNED=true
fi

# Ensure the symlink structure exists in /config/keys so that SWAG's built-in
# init-keygen script (which runs next, via s6-overlay) sees existing files and
# skips its fallback that would otherwise generate a linuxserver.io self-signed
# cert as a real file, replacing our symlinks.
#
# In STAGING mode the live-path already has the self-signed cert written above,
# so the symlinks resolve correctly from the start.
# In production mode certbot will place real certs at the live-path shortly;
# the symlink skeleton just prevents init-keygen from running first.
mkdir -p "$(dirname "$LE_LIVE_DIR")"
rm -f /config/keys/letsencrypt /config/keys/cert.crt /config/keys/cert.key
ln -s "../etc/letsencrypt/live/${URL:-example.com}" /config/keys/letsencrypt
ln -s ./letsencrypt/fullchain.pem /config/keys/cert.crt
ln -s ./letsencrypt/privkey.pem /config/keys/cert.key

if [ "$USE_SELF_SIGNED" = "true" ]; then
    if [ ! -f "$LE_LIVE_DIR/fullchain.pem" ] || [ ! -f "$LE_LIVE_DIR/privkey.pem" ]; then
        echo ">>> Pre-seeding self-signed fallback certificate at ${LE_LIVE_DIR} ..."
        rm -rf "$LE_LIVE_DIR"
        mkdir -p "$LE_LIVE_DIR"
        openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
            -keyout "$LE_LIVE_DIR/privkey.pem" \
            -out "$LE_LIVE_DIR/fullchain.pem" \
            -subj "/CN=${URL:-example.com}/O=SWAG/C=DE" \
            -addext "subjectAltName=DNS:${URL:-example.com},DNS:localhost,IP:127.0.0.1"
        echo ">>> Self-signed fallback certificate seeded"
    fi
else
    echo ">>> Production mode: Let's Encrypt will manage certificates for ${URL}"
fi

echo ">>> Starting SWAG (domain=${URL}, validation=${VALIDATION:-http}, staging=${STAGING:-false})..."

exec /init
