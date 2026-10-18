#!/usr/bin/env bash
set -Eeuo pipefail

DOMAIN="vault-7x4k.tplinkdns.com"
CADDY_VERSION="2.11.7"
HOME_DIR="/home/phablet"
CADDY_BIN="${HOME_DIR}/.local/bin/caddy"
RCLONE_BIN="${HOME_DIR}/.local/bin/rclone"
VAULT_DIR="${HOME_DIR}/Documents/ObsidianVault"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

case "$(uname -m)" in
  aarch64|arm64) ;;
  *) echo "Ошибка: этот файл рассчитан на ARM64." >&2; exit 1 ;;
esac

test -x "${RCLONE_BIN}" || { echo "Ошибка: rclone не найден: ${RCLONE_BIN}" >&2; exit 1; }

cd "${TMP_DIR}"
ARCHIVE="caddy_${CADDY_VERSION}_linux_arm64.tar.gz"
CHECKSUMS="caddy_${CADDY_VERSION}_checksums.txt"
BASE_URL="https://github.com/caddyserver/caddy/releases/download/v${CADDY_VERSION}"

wget -q --show-progress "${BASE_URL}/${ARCHIVE}"
wget -q --show-progress "${BASE_URL}/${CHECKSUMS}"
grep " ${ARCHIVE}$" "${CHECKSUMS}" | sha512sum -c -
tar -xzf "${ARCHIVE}" caddy

mkdir -p \
  "${HOME_DIR}/.local/bin" \
  "${HOME_DIR}/.config/caddy" \
  "${HOME_DIR}/.local/share/caddy" \
  "${HOME_DIR}/.config/systemd/user" \
  "${VAULT_DIR}"
install -m 755 caddy "${CADDY_BIN}"

if command -v openssl >/dev/null 2>&1; then
  DAV_PASSWORD="$(openssl rand -hex 24)"
else
  DAV_PASSWORD="$(head -c 24 /dev/urandom | od -An -tx1 | tr -d ' \n')"
fi
DAV_HASH="$("${CADDY_BIN}" hash-password --plaintext "${DAV_PASSWORD}")"
printf '%s\n' "${DAV_PASSWORD}" > "${HOME_DIR}/.config/caddy/obsidian-password"
chmod 600 "${HOME_DIR}/.config/caddy/obsidian-password"

cat > "${HOME_DIR}/.config/caddy/Caddyfile" <<EOF
{
	http_port 8081
	https_port 8443
	admin off
}

${DOMAIN} {
	basic_auth {
		obsidian ${DAV_HASH}
	}

	reverse_proxy 127.0.0.1:8080 {
		header_up -Authorization
	}
}
EOF
chmod 600 "${HOME_DIR}/.config/caddy/Caddyfile"

cat > "${HOME_DIR}/.config/systemd/user/obsidian-webdav.service" <<'EOF'
[Unit]
Description=Obsidian WebDAV storage
After=network-online.target

[Service]
Type=simple
ExecStart=/home/phablet/.local/bin/rclone serve webdav /home/phablet/Documents/ObsidianVault --addr 127.0.0.1:8080 --baseurl /obsidian --log-level INFO
Restart=always
RestartSec=5
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=read-only
ReadWritePaths=/home/phablet/Documents/ObsidianVault
UMask=0077

[Install]
WantedBy=default.target
EOF

cat > "${HOME_DIR}/.config/systemd/user/caddy.service" <<'EOF'
[Unit]
Description=HTTPS gateway for Obsidian WebDAV
After=network-online.target obsidian-webdav.service
Requires=obsidian-webdav.service

[Service]
Type=simple
Environment=HOME=/home/phablet
Environment=XDG_CONFIG_HOME=/home/phablet/.config
Environment=XDG_DATA_HOME=/home/phablet/.local/share
ExecStart=/home/phablet/.local/bin/caddy run --config /home/phablet/.config/caddy/Caddyfile --adapter caddyfile
Restart=always
RestartSec=5
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=read-only
ReadWritePaths=/home/phablet/.local/share/caddy /home/phablet/.config/caddy
UMask=0077

[Install]
WantedBy=default.target
EOF

"${CADDY_BIN}" validate --config "${HOME_DIR}/.config/caddy/Caddyfile" --adapter caddyfile

systemctl --user disable --now tailscaled-userspace.service >/dev/null 2>&1 || true
rm -f \
  "${HOME_DIR}/.config/systemd/user/tailscaled-userspace.service" \
  "${HOME_DIR}/.local/bin/tailscale" \
  "${HOME_DIR}/.local/bin/tailscaled"
rm -rf "${HOME_DIR}/.local/share/tailscale"

systemctl --user daemon-reload
systemctl --user enable --now obsidian-webdav.service caddy.service

echo
echo "ГОТОВО"
echo "Адрес: https://${DOMAIN}/obsidian/"
echo "Логин: obsidian"
echo "Пароль: ${DAV_PASSWORD}"
echo
echo "Пароль также сохранён в ~/.config/caddy/obsidian-password"
echo "Не отправляйте пароль в чат."
echo
systemctl --user --no-pager --full is-active obsidian-webdav.service caddy.service
