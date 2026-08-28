# antiX Edition

The current release of LiviOS, designed for older hardware and 32‑bit systems.
It is delivered as a **post‑install installer** that runs on top of a minimal
**antiX‑core** installation — there is no live ISO.

## Overview
This edition serves as the foundational implementation of LiviOS, focusing on a
lightweight, retro‑inspired experience built on antiX-core.

## Installation
1. Install a minimal **antiX-core** system (32‑bit).
2. Copy `install.sh` to the installed system (e.g. via USB stick or scp).
3. Run as root:
   ```sh
   ./install.sh
   ```
4. Reboot — you land on the C64‑themed Openbox desktop.

The installer works with **either** the **runit** or **sysvinit** init system; it
detects the active one automatically. It installs the required packages, copies
all LiviOS files into place (per the [file manifest](../../docs/file-manifest/README.md)),
configures the splash and tty1 autologin, refreshes fonts, and runs
`update-grub`.

For an overview of what the script does, see the comments at the top of
`install.sh`. To change which files/packages are installed, edit the manifest CSV
and `packages.list`, then regenerate the installer:

```sh
editions/antix/scripts/make-installer.sh
```

## Components
- **Custom GRUB theme**
- **Custom splash screen**
- **Openbox environment**
- **C64‑themed URxvt terminal**
- **Autologin + startx on tty1**
- **Runit services (and sysvinit equivalent)**
- **Demo user environment**
- **Curated lightweight applications**

## Package list
- `packages.list` — packages installed by `install.sh` (Openbox, URxvt, X server,
  fim, games, etc.).

## Documentation
- [File Manifest](../../docs/file-manifest/README.md)
