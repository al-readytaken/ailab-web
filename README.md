# ailab-web

Standalone web services for the AI Lab stack. Extracted from the monolith `mps-ailab` docker-compose so each web service can be deployed independently.

## Services

| Service | Port(s) | Description |
|---------|---------|-------------|
| **openwebui** | 3001 (direct), 80/443 (via SWAG) | Chat UI for Ollama |
| **swag** | 80, 443 | Reverse proxy with automatic HTTPS |
| **kokoro** | 8880 | TTS (text-to-speech) service |

## Structure

```
ailab-web/
├── docker-compose.yml       # Orchestrates all services
├── .env                     # Central config (ports, paths, secrets)
├── common/ssh/              # Shared SSH keys + sshd_config
├── openwebui/               # Open WebUI service
│   ├── Dockerfile
│   ├── .env
│   ├── scripts/entrypoint.bash
│   └── data/                # Persistent data (gitignored)
├── swag/                    # SWAG reverse proxy
│   ├── Dockerfile
│   ├── .env
│   ├── nginx/default.conf   # Site config (proxy rules)
│   ├── scripts/entrypoint.sh
│   └── data/certs/          # SSL certificate symlinks
├── kokoro/                  # Kokoro TTS service
│   ├── Dockerfile
│   ├── .env
│   ├── scripts/entrypoint.sh
│   └── data/                # Persistent data (gitignored)
└── <future-service>/        # Future services go here
```

## Dependencies

- **openwebui** requires **ollama** running on the `ailab-local` Docker network (provided by `ailab-localai`).
- **swag** depends on **openwebui** — proxying is configured in `swag/nginx/default.conf`.
- **kokoro** is stand-alone.

## Usage

```bash
# Start all services
docker compose up -d

# Start a specific service
docker compose up -d openwebui

# View logs
docker compose logs -f

# Rebuild and restart
docker compose build openwebui && docker compose up -d openwebui
```

### HTTPS Access (via SWAG)

Once deployed, Open WebUI is available at:

```
https://openwebui-local
```

SWAG proxies HTTPS (port 443) → Open WebUI (port 8080).  
In development mode (`STAGING=true` in `swag/.env`) a self-signed certificate is generated — your browser will show a security warning that you must accept.

SWAG also redirects HTTP (port 80) → HTTPS.

#### Nginx configuration

The SWAG site config is at `swag/nginx/default.conf`. It is mounted into the container at `/config/nginx/site-confs/default.conf`. After editing, reload with:

```bash
docker exec swag nginx -s reload
```

Key settings in the config:
- HTTP → HTTPS redirect on port 80
- HTTPS server on port 443 with SSL from `ssl.conf`
- WebSocket upgrade headers for socket.io (`Connection`, `Upgrade`)
- SSE streaming: `proxy_buffering off; proxy_cache off; tcp_nodelay on`
- Extended timeouts (30 min for API, 24 h for WebSocket)

### Direct Access (bypassing SWAG)

You can also access Open WebUI directly on port 3001:

```
http://localhost:3001
```

Useful for testing or if you don't need HTTPS.

## Adding a New Service

1. Create a new folder (e.g. `my-service/`) with `Dockerfile`, `.env`, and `scripts/entrypoint.sh`
2. Add the service block to `docker-compose.yml`
3. Add the corresponding variables to `.env`
4. Optionally add a proxy location in `swag/nginx/default.conf`
5. Run `docker compose up -d`

## SSH Access

```bash
ssh -p 22002 root@localhost   # openwebui
```

Root password is set in `openwebui/.env` (`ROOT_PASSWORD`).

## Networks

- `ailab-web` — internal bridge for all web services to communicate
- `ailab-local` — external bridge (from `ailab-localai`) for Ollama access
