# Stage 1: Build caddy with plugins (with aggressive caching)
FROM caddy:2.15.0-builder AS builder

# Multi-layer caching for maximum speedup
# hadolint ignore=DL3029
RUN --mount=type=cache,target=/root/.cache/go-build,sharing=locked \
    --mount=type=cache,target=/root/go/pkg/mod,sharing=locked \
    --mount=type=cache,target=/root/.cache,sharing=locked \
    xcaddy build \
    --with github.com/caddy-dns/cloudflare \
    --output /caddy

# Stage 2: Runtime image (minimal, distroless for security)
FROM caddy:2.10.2

# Use COPY --link for faster layer operations
COPY --from=builder --link /caddy /usr/bin/caddy
