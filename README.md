# caddy-cloudflare

Caddy built from the official `caddy` builder and runtime images with three modules:

| Module | Source |
|---|---|
| `dns.providers.cloudflare` | `github.com/caddy-dns/cloudflare` v0.2.4 |
| `http.ip_sources.cloudflare` | `github.com/WeidiDeng/caddy-cloudflare-ip` (pinned commit) |
| `http.ip_sources.combine` | `github.com/fvbommel/caddy-combine-ip-ranges` v0.0.1 |

`ghcr.io/shaman-rostov/caddy-cloudflare:<caddy version>` for linux/arm64 and linux/amd64, rebuilt weekly so Alpine
fixes (`apk upgrade`) and the builder's Go release reach the image. `test.sh <image>` checks the modules, validates a
config that uses them and serves a site.

Updating Caddy: change both base image tags/digests and `ARG CADDY_VERSION` together.
