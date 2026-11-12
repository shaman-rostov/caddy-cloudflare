# Caddy with the Cloudflare DNS provider and Cloudflare IP ranges, built from the official images.
# Replaces the third-party ghcr.io/caddybuilds/caddy-cloudflare on the oracle reverse proxy: same three modules,
# built here so the Go toolchain and Alpine packages are current (weekly rebuild). The Go build stage is the official
# golang image rather than caddy's builder, which lags behind Go security releases.
ARG CADDY_VERSION=2.11.9
ARG XCADDY_VERSION=v0.4.7

# cross-compiled on the build platform (no emulation); xcaddy honours GOOS/GOARCH
FROM --platform=$BUILDPLATFORM golang:1.27.4-alpine@sha256:0a5f7fe796599ff487605987432e7619ae45beeb2fba4c2ce0b907879932aebf AS build
ARG CADDY_VERSION XCADDY_VERSION TARGETOS TARGETARCH
RUN apk add --no-cache git \
 && go install github.com/caddyserver/xcaddy/cmd/xcaddy@$XCADDY_VERSION \
 && GOOS=$TARGETOS GOARCH=$TARGETARCH xcaddy build v${CADDY_VERSION} --output /caddy \
      --with github.com/caddy-dns/cloudflare@v0.2.4 \
      --with github.com/WeidiDeng/caddy-cloudflare-ip@f53b62aa13cb7ad79c8b47aacc3f2f03989b67e5 \
      --with github.com/fvbommel/caddy-combine-ip-ranges@v0.0.1

FROM caddy:2.11.9-alpine@sha256:0bbb055bda6793c999bde78b1b5ce3e89f829fb031af2cf50056ea1246559fee
RUN apk upgrade --no-cache
COPY --from=build /caddy /usr/bin/caddy
