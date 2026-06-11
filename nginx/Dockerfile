FROM nginx:alpine

RUN apk add --no-cache openssl

COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf
COPY nginx/scripts/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
