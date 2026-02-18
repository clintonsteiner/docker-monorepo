[![Latest Release][version-image]][version-url]
[![caddy on DockerHub][dockerhub-image]][dockerhub-url]
[![Docker Build][gh-actions-image]][gh-actions-url]

# caddy-cloudflaredns

A Docker image for [Caddy](https://caddyserver.com/) with built-in support for DNS validation using [Cloudflare DNS](https://www.cloudflare.com/). This image enables automatic TLS certificate generation and renewal for domains managed on Cloudflare.

**Please see the official [Caddy Docker Image](https://hub.docker.com/_/caddy) for general deployment instructions.**

## Features

- Pre-built Caddy binary with Cloudflare DNS module
- Automated TLS certificate generation and renewal via ACME
- DNS-01 challenge support for wildcard certificates
- Multi-platform support (amd64, arm64, arm/v8, arm/v7)
- Automatic version tagging synchronized with upstream Caddy releases

## Prerequisites

- Docker (version 20.10 or later)
- Cloudflare domain and API token
- Basic knowledge of Docker and Caddy configuration

## Quick Start

### 1. Prepare Your Cloudflare Credentials

Create an API token in your Cloudflare dashboard with the following permissions:

| Permission Category | Scope | Permission |
|---|---|---|
| Zone | Zone | Read |
| Zone | DNS | Edit |

**Important:** For security, create a token with minimal permissions scoped only to the zone(s) you will manage.

Detailed instructions: [Cloudflare API Token Documentation](https://support.cloudflare.com/hc/en-us/articles/200167836-Managing-API-Tokens-and-Keys)

### 2. Basic Docker Run

```bash
docker run -d --name caddy \
  -p 80:80 \
  -p 443:443 \
  -v caddy_data:/data \
  -v caddy_config:/config \
  -v $PWD/Caddyfile:/etc/caddy/Caddyfile \
  -e CLOUDFLARE_EMAIL=me@example.com \
  -e CLOUDFLARE_API_TOKEN=your_api_token \
  -e ACME_AGREE=true \
  clintonsteiner/caddy-cloudflaredns:latest
```

### 3. Configure Caddy with Cloudflare DNS

Add the following to your `Caddyfile`:

```caddy
{
  acme_dns cloudflare {$CLOUDFLARE_API_TOKEN}
}

example.com, www.example.com {
  tls {$CLOUDFLARE_EMAIL} {
    dns cloudflare {$CLOUDFLARE_API_TOKEN}
  }

  reverse_proxy localhost:3000
}
```

### 4. Docker Compose Example

Create a `docker-compose.yml` for production use:

```yaml
version: '3.8'

services:
  caddy:
    image: clintonsteiner/caddy-cloudflaredns:latest
    container_name: caddy
    restart: unless-stopped

    ports:
      - "80:80"
      - "443:443"

    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - caddy_data:/data
      - caddy_config:/config

    environment:
      CLOUDFLARE_EMAIL: ${CLOUDFLARE_EMAIL}
      CLOUDFLARE_API_TOKEN: ${CLOUDFLARE_API_TOKEN}
      ACME_AGREE: 'true'

    networks:
      - caddy_net

volumes:
  caddy_data:
  caddy_config:

networks:
  caddy_net:
    driver: bridge
```

Create a `.env` file:

```env
CLOUDFLARE_EMAIL=me@example.com
CLOUDFLARE_API_TOKEN=your_api_token_here
```

Start the service:

```bash
docker-compose up -d
```

## Available Docker Images

Builds are automatically published to multiple container registries:

| Registry | URL |
|---|---|
| Docker Hub | `docker.io/clintonsteiner/caddy-cloudflaredns` |
| GitHub Container Registry | `ghcr.io/clintonsteiner/caddy-cloudflaredns` |
| Quay Container Registry | `quay.io/clintonsteiner/caddy-cloudflaredns` |

### Version Tags

This image supports tagging by Caddy version. [View available tags](https://hub.docker.com/r/clintonsteiner/caddy-cloudflaredns/tags).

```bash
# Use specific Caddy version
docker pull clintonsteiner/caddy-cloudflaredns:2.10.2

# Use latest version
docker pull clintonsteiner/caddy-cloudflaredns:latest
```

## Environment Variables

| Variable | Required | Description |
|---|---|---|
| `CLOUDFLARE_EMAIL` | Yes | Your Cloudflare account email address |
| `CLOUDFLARE_API_TOKEN` | Yes | Your Cloudflare API token with DNS edit permissions |
| `ACME_AGREE` | Yes | Set to `true` to agree to Let's Encrypt terms of service |

## Volumes

| Volume | Purpose |
|---|---|
| `/data` | Persistent storage for certificates and ACME state |
| `/config` | Caddy configuration and cache |
| `/etc/caddy/Caddyfile` | Your Caddyfile configuration (typically mounted read-only) |

## Security Considerations

- **Never commit `.env` files or API tokens to version control**
- Use Docker secrets in production Swarm mode
- Ensure proper file permissions on volumes: `chmod 600 .env`
- Regularly rotate Cloudflare API tokens
- Use read-only mounts for your Caddyfile when possible

## Troubleshooting

### Certificate Generation Fails

1. Verify Cloudflare credentials are correct
2. Check that your domain is registered with Cloudflare
3. Ensure the API token has zone read and DNS edit permissions
4. Verify your Caddyfile syntax with `caddy validate`

### Check Logs

```bash
docker logs -f caddy
```

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for development setup, testing guidelines, and the pull request process.

## License

This project is released under the same license as Caddy. See the [Caddy repository](https://github.com/caddyserver/caddy) for details.

## References

- [Caddy Documentation](https://caddyserver.com/docs/)
- [Caddy Docker Image](https://hub.docker.com/_/caddy)
- [Caddy DNS Plugins](https://caddyserver.com/docs/json/apps/tls/automation/policies/issuers/acme/challenges/dns/)
- [Cloudflare API Documentation](https://developers.cloudflare.com/)

---

[version-image]: https://img.shields.io/github/v/release/clintonsteiner/caddy-cloudflaredns?style=for-the-badge
[version-url]: https://github.com/clintonsteiner/caddy-cloudflaredns/releases

[gh-actions-image]: https://img.shields.io/github/actions/workflow/status/clintonsteiner/caddy-cloudflaredns/main.yml?style=for-the-badge
[gh-actions-url]: https://github.com/clintonsteiner/caddy-cloudflaredns/actions

[dockerhub-image]: https://img.shields.io/docker/pulls/clintonsteiner/caddy-cloudflaredns?label=DockerHub%20Pulls&style=for-the-badge
[dockerhub-url]: https://hub.docker.com/r/clintonsteiner/caddy-cloudflaredns
