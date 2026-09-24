# VMware Wayland Clipboard Bridge

A small workaround for guest-to-host text clipboard synchronization in VMware Linux guests running KDE Plasma on Wayland.

## Problem

On some VMware Workstation Linux guests running Wayland, clipboard integration is asymmetric:

```text
Windows host -> Linux guest     works
Linux guest -> Windows host     does not
```

`vmware-user` can see the X11/XWayland clipboard, while text copied by native Wayland applications may not reach it.

This project bridges normal Wayland text clipboard updates into X11 so VMware can forward them to the host.

It also avoids two issues found during testing:

- Wayland/XWayland clipboard feedback loops
- breaking Dolphin file copy/cut operations by treating file clipboard data as plain text

Dolphin file transfers are detected and left untouched.

## Tested environment

- Windows 11 host
- VMware Workstation 26H1u1
- Fedora 44 KDE Plasma guest
- Wayland
- `open-vm-tools`
- `open-vm-tools-desktop`
- XWayland

## How it works

For normal text:

```text
Wayland clipboard
      |
      v
wl-paste --watch
      |
      v
helper script
      |
      v
xclip / X11 clipboard
      |
      v
vmware-user
      |
      v
Windows clipboard
```

The helper suppresses immediate reflected clipboard updates so it does not react to its own changes.

For Dolphin file copy/cut operations, the helper detects KDE file-transfer MIME types such as:

```text
text/uri-list
application/x-kde4-urilist
application/vnd.portal.filetransfer
application/x-kde-source-id
```

and ignores the event, allowing Dolphin to handle file operations normally.

This project only bridges text. It does not attempt to transfer files through VMware.

## Requirements

On Fedora:

```bash
sudo dnf install wl-clipboard xclip util-linux coreutils
```

VMware guest tools should also be installed:

```bash
sudo dnf install open-vm-tools open-vm-tools-desktop
```

The session must be running Wayland with XWayland available.

## Install

Clone the repository and run the installer:

```bash
git clone https://github.com/itzViking/vmware-wayland-clipboard.git
cd vmware-wayland-clipboard
./install.sh
```

`install.sh`:

- checks the required commands
- installs the helper to `~/.local/bin/`
- installs the systemd user service to `~/.config/systemd/user/`
- enables and starts the service

Check status with:

```bash
systemctl --user status vmware-wayland-clipboard.service
```

## Uninstall

From the repository directory:

```bash
./uninstall.sh
```

This stops and disables the user service, removes the installed helper and service file, and clears the runtime state files.

## Limitations

This is a compatibility workaround, not native VMware Wayland clipboard support.

It currently targets:

- guest-to-host text clipboard synchronization
- KDE Plasma on Wayland
- VMware using the X11/XWayland clipboard path

It does not bridge:

- files
- images
- drag and drop
- arbitrary clipboard MIME formats

Dolphin file copy/cut operations are intentionally ignored so they continue to work normally inside the guest.

## License

MIT
