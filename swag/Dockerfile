FROM lscr.io/linuxserver/swag

COPY swag/scripts/entrypoint.sh /custom-entrypoint.sh
COPY swag/nginx/default.conf /default-site.conf

RUN chmod +x /custom-entrypoint.sh

ENTRYPOINT ["/custom-entrypoint.sh"]
