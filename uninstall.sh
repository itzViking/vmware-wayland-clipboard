#!/usr/bin/env bash
set -euo pipefail

systemctl --user disable --now vmware-wayland-clipboard.service 2>/dev/null || true
rm -f "$HOME/.config/systemd/user/vmware-wayland-clipboard.service"
rm -f "$HOME/.local/bin/vmware-wayland-clipboard"
rm -f "${XDG_RUNTIME_DIR:-/tmp}/vmware-wayland-clipboard.state"
rm -f "${XDG_RUNTIME_DIR:-/tmp}/vmware-wayland-clipboard.lock"
systemctl --user daemon-reload

printf 'Removed VMware Wayland clipboard bridge.\n'
