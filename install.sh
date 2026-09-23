#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

missing=()
for cmd in wl-paste xclip sha256sum flock; do
    command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
done

if ((${#missing[@]})); then
    printf 'Missing required commands: %s\n' "${missing[*]}" >&2
    printf 'On Fedora, install them with:\n  sudo dnf install wl-clipboard xclip util-linux coreutils\n' >&2
    exit 1
fi

install -d "$HOME/.local/bin" "$HOME/.config/systemd/user"
install -m 0755 "$repo_dir/bin/vmware-wayland-clipboard" "$HOME/.local/bin/vmware-wayland-clipboard"
install -m 0644 "$repo_dir/systemd/user/vmware-wayland-clipboard.service" "$HOME/.config/systemd/user/vmware-wayland-clipboard.service"

systemctl --user daemon-reload
systemctl --user enable --now vmware-wayland-clipboard.service

printf '\nInstalled and started vmware-wayland-clipboard.service\n'
printf 'Check it with:\n  systemctl --user status vmware-wayland-clipboard.service\n'
