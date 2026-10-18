#!/usr/bin/env bash
set -Eeuo pipefail

NEW_PASS="$(openssl rand -hex 24)"
NEW_HASH="$("$HOME/.local/bin/caddy" hash-password --plaintext "$NEW_PASS")"

printf '%s\n' "$NEW_PASS" > "$HOME/.config/caddy/obsidian-password"
chmod 600 "$HOME/.config/caddy/obsidian-password"

cat > "$HOME/.config/caddy/Caddyfile" <<EOF
{
	http_port 8081
	https_port 8443
	admin off
}

vault-7x4k.tplinkdns.com {
	basic_auth {
		obsidian ${NEW_HASH}
	}

	reverse_proxy 127.0.0.1:8080 {
		header_up -Authorization
	}
}
EOF

chmod 600 "$HOME/.config/caddy/Caddyfile"
unset NEW_PASS NEW_HASH

"$HOME/.local/bin/caddy" validate --config "$HOME/.config/caddy/Caddyfile" --adapter caddyfile >/dev/null
systemctl --user restart caddy.service
systemctl --user is-active caddy.service
