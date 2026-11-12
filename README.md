# caddy-cloudflare

Caddy built with xcaddy on the official `golang` image (current Go security releases; caddy's own builder lags)
and shipped on the official `caddy` runtime image, with three modules:

| Module | Source |
|---|---|
| `dns.providers.cloudflare` | `github.com/caddy-dns/cloudflare` v0.2.4 |
| `http.ip_sources.cloudflare` | `github.com/WeidiDeng/caddy-cloudflare-ip` (pinned commit) |
| `http.ip_sources.combine` | `github.com/fvbommel/caddy-combine-ip-ranges` v0.0.1 |

`ghcr.io/shaman-rostov/caddy-cloudflare:<caddy version>` for linux/arm64 and linux/amd64, rebuilt weekly so Alpine
fixes (`apk upgrade`) reach the image; Dependabot bumps the `golang` and `caddy` digests. `test.sh <image>` checks the modules, validates a
config that uses them and serves a site.

Updating Caddy: change both base image tags/digests and `ARG CADDY_VERSION` together.
