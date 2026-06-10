# ailab-web

Standalone web services for the AI Lab stack. Extracted from the monolith `mps-ailab` docker-compose so each web service can be deployed independently.

## Services

| Service | Web Port | SSH Port | Description |
|---------|----------|----------|-------------|
| **openwebui** | 3001 | 22002 | Chat UI for Ollama |

## Structure

```
ailab-web/
├── docker-compose.yml       # Orchestrates all web services
├── .env                     # Central config (ports, paths)
├── common/ssh/              # Shared SSH keys + sshd_config
├── openwebui/               # Open WebUI service
│   ├── Dockerfile
│   ├── .env
│   ├── .env.example
│   ├── scripts/entrypoint.bash
│   └── data/                # Persistent data (gitignored)
└── <future-webui>/          # Future web services go here
```

## Dependencies

- **openwebui** requires **ollama** running on the `ailab-local` Docker network (provided by `ailab-localai`).

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

## Adding a New Web Service

1. Create a new folder (e.g. `my-webui/`) with its own `Dockerfile`, `.env`, and `scripts/entrypoint.bash`
2. Add the service block to `docker-compose.yml`
3. Add the corresponding variables to `.env`
4. Run `docker compose up -d`

## SSH Access

```bash
ssh -p 22002 root@localhost  # openwebui
```

## Networks

- `ailab-web` — internal bridge for web services to communicate
- `ailab-local` — external bridge (from `ailab-localai`) for Ollama access