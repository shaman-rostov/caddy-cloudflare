#!/usr/bin/env bash
# Checks the image (CF_API_TOKEN is a format-valid placeholder, never used): the expected modules are compiled in, a config using them validates, and a site is served.
set -euo pipefail
IMAGE=${1:?image}
MODULES=(dns.providers.cloudflare http.ip_sources.cloudflare http.ip_sources.combine)
mods=$(docker run --rm "$IMAGE" caddy list-modules)
for m in "${MODULES[@]}"; do grep -qx "$m" <<<"$mods" || { echo "FAIL: module $m missing"; exit 1; }; done
dir=$(mktemp -d)
cat > "$dir/Caddyfile" <<'CFG'
{
	servers {
		trusted_proxies combine {
			cloudflare
			static 127.0.0.1/8
		}
	}
}
tls.example.com {
	tls {
		dns cloudflare {env.CF_API_TOKEN}
	}
	respond "tls"
}
:8080 {
	respond "ok-test"
}
CFG
chmod -R a+rX "$dir"
docker run --rm -e CF_API_TOKEN=0123456789abcdefghijklmnopqrstuvwxyzABCD -v "$dir:/etc/caddy:ro" "$IMAGE" caddy validate --config /etc/caddy/Caddyfile >/dev/null \
  || { echo "FAIL: caddy validate"; exit 1; }
# serving check without the DNS site (validate above covers it; serving it would try to obtain a certificate)
printf ':8080 {\n\trespond "ok-test"\n}\n' > "$dir/Caddyfile"
name=caddy-test-$$
trap 'docker rm -f "$name" >/dev/null 2>&1 || true; rm -rf "$dir"' EXIT
docker run -d --name "$name" -p 127.0.0.1::8080 -v "$dir:/etc/caddy:ro" "$IMAGE" >/dev/null
port=$(docker port "$name" 8080/tcp | head -1 | sed 's/.*://')
for _ in $(seq 20); do curl -fsS "http://127.0.0.1:$port/" 2>/dev/null | grep -q ok-test && break; sleep 1; done
curl -fsS "http://127.0.0.1:$port/" | grep -q ok-test || { echo "FAIL: not served"; docker logs "$name"; exit 1; }
echo "PASS $(docker run --rm "$IMAGE" caddy version | cut -d' ' -f1)"
