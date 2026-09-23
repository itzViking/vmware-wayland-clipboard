# VMware Wayland Clipboard Bridge

Workaround for guest-to-host text clipboard synchronization in VMware Linux
guests running a Wayland desktop.

Tested with:

- Windows 11 host
- VMware Workstation 26H1u1
- Fedora 44 KDE Plasma guest
- Wayland session
- open-vm-tools 13.1.0
- XWayland enabled

## Problem

With a Wayland guest, VMware clipboard integration may work from host to guest
but fail from guest to host.

`vmware-user` still interacts with the X11/XWayland clipboard. Native Wayland
applications therefore may not make their clipboard contents visible to VMware.

Manually running:

    wl-paste | xclip -selection clipboard

makes the current Wayland clipboard available through X11 and consequently to
the VMware host.

Using `wl-paste --watch` with `xclip` directly can cause clipboard feedback
between Wayland and XWayland, so this workaround adds duplicate suppression.

## How it works

The bridge follows this path:

    Wayland application
        |
        v
    wl-paste --watch
        |
        v
    duplicate/reflection suppression
        |
        v
    xclip / X11 clipboard
        |
        v
    vmware-user
        |
        v
    VMware host clipboard

The helper hashes clipboard contents and suppresses an immediate reflected copy
for a short period.

An important implementation detail is that `xclip` daemonizes so it can remain
the X11 clipboard owner. The helper therefore releases its `flock` file
descriptor before launching `xclip`. Otherwise the background xclip process can
inherit the lock and block subsequent clipboard updates.

## Requirements

On Fedora:

    sudo dnf install wl-clipboard xclip

The guest must also have VMware desktop integration installed and running,
normally through:

    open-vm-tools
    open-vm-tools-desktop

XWayland must be available because this workaround deliberately bridges the
Wayland clipboard into the X11 clipboard used by VMware.

## Installation

Copy the helper:

    mkdir -p ~/.local/bin
    install -m 755 bin/vmware-wayland-clipboard \
        ~/.local/bin/vmware-wayland-clipboard

Install the user service:

    mkdir -p ~/.config/systemd/user
    install -m 644 systemd/user/vmware-wayland-clipboard.service \
        ~/.config/systemd/user/

Reload and enable it:

    systemctl --user daemon-reload
    systemctl --user enable --now vmware-wayland-clipboard.service

Check status:

    systemctl --user status vmware-wayland-clipboard.service

## Troubleshooting

Verify Wayland clipboard monitoring:

    wl-paste --type text --watch sh -c 'cat > /tmp/wlwatch'

Verify the one-shot Wayland to X11 bridge:

    wl-paste | xclip -selection clipboard

Verify the X11 clipboard:

    xclip -selection clipboard -out

Check processes:

    pgrep -af 'wl-paste|xclip|vmware-wayland-clipboard'

## Limitations

This is a workaround, not native VMware Wayland clipboard support.

Currently it is intended for:

- text clipboard data
- guest-to-host synchronization
- Wayland sessions with XWayland available

It does not implement file copy, drag-and-drop, images, or arbitrary clipboard
MIME types.

## Upstream

The underlying Wayland clipboard limitation is tracked in the open-vm-tools
issue tracker, including:

- vmware/open-vm-tools#792
- vmware/open-vm-tools#443

## License

MIT