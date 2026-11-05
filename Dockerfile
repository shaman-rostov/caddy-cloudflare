# Caddy with the Cloudflare DNS provider and Cloudflare IP ranges, built from the official images.
# Replaces the third-party ghcr.io/caddybuilds/caddy-cloudflare on the oracle reverse proxy: same three modules,
# built here so the Go toolchain and Alpine packages are current (weekly rebuild).
ARG CADDY_VERSION=2.11.8

# cross-compiled on the build platform (no emulation); xcaddy honours GOOS/GOARCH
FROM --platform=$BUILDPLATFORM caddy:2.11.8-builder-alpine@sha256:e42a64b3bc70aa3a1387bde85b930e507a378fecae5852d5bfde9dcd37d0b999 AS build
ARG CADDY_VERSION TARGETOS TARGETARCH
RUN GOOS=$TARGETOS GOARCH=$TARGETARCH xcaddy build v${CADDY_VERSION} --output /caddy \
      --with github.com/caddy-dns/cloudflare@v0.2.4 \
      --with github.com/WeidiDeng/caddy-cloudflare-ip@f53b62aa13cb7ad79c8b47aacc3f2f03989b67e5 \
      --with github.com/fvbommel/caddy-combine-ip-ranges@v0.0.1

FROM caddy:2.11.8-alpine@sha256:f6228111e5fafa1a5238258d0858e103f10599b8d1659a146e7726681a002bb9
RUN apk upgrade --no-cache
COPY --from=build /caddy /usr/bin/caddy
