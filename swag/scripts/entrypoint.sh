#!/bin/bash
set -e

SITE_CONF=/config/nginx/site-confs/default.conf

# Deploy default nginx site config on first run
if [ ! -f "$SITE_CONF" ]; then
    mkdir -p "$(dirname "$SITE_CONF")"
    cp /default-site.conf "$SITE_CONF"
    echo ">>> Deployed default nginx site config"
fi

# Pre-seed self-signed certs at the symlink target
# The init-certbot-config script always does:
#   rm -rf /config/keys/letsencrypt && ln -s ../etc/letsencrypt/live/${URL} /config/keys/letsencrypt
# Then checks /config/keys/letsencrypt/fullchain.pem (through symlink).
# If we seed certs at the target path first, the check succeeds and certbot is skipped.
LE_LIVE_DIR="/config/etc/letsencrypt/live/${URL:-example.com}"
if [ ! -f "$LE_LIVE_DIR/fullchain.pem" ] || [ ! -f "$LE_LIVE_DIR/privkey.pem" ]; then
    echo ">>> Pre-seeding self-signed fallback certificate at ${LE_LIVE_DIR} ..."
    rm -rf "$LE_LIVE_DIR"
    mkdir -p "$LE_LIVE_DIR"
    openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
        -keyout "$LE_LIVE_DIR/privkey.pem" \
        -out "$LE_LIVE_DIR/fullchain.pem" \
        -subj "/CN=${URL:-example.com}/O=SWAG/C=DE"
    echo ">>> Self-signed fallback certificate seeded"
fi

echo ">>> Starting SWAG (domain=${URL}, validation=${VALIDATION:-http}, staging=${STAGING:-false})..."

exec /init
