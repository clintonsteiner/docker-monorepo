# Stage 1: Build caddy with plugins (cached for faster rebuilds)
FROM caddy:2.10.2-builder AS builder

# Cache go build artifacts for faster rebuilds
# hadolint ignore=DL3029
RUN --mount=type=cache,target=/root/.cache/go-build \
    xcaddy build \
    --with github.com/caddy-dns/cloudflare

# Stage 2: Runtime image (minimal, only contains binary)
FROM caddy:2.10.2

# Copy pre-built caddy binary from builder stage
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
