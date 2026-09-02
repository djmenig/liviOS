# LiviOS openSUSE Edition

A **64-bit live ISO** of LiviOS built with **KIWI NG**, based on a minimal
**openSUSE Leap 15.6** system. It reproduces the full LiviOS experience —
custom bootloader theme, boot splash, tty1 autologin, and a C64-themed
Openbox + URxvt terminal environment — directly from the live media.

This edition differs fundamentally from the [antiX edition](../antix/):
antiX is a **post-install installer** (a shell script run on top of an
installed antiX-core system), whereas openSUSE is an **image** built ahead of
time with KIWI NG. There is nothing to install afterwards — boot the ISO and
you are in LiviOS.

---

## Building the ISO

Full, step-by-step instructions live in [`BUILDING.md`](BUILDING.md) (install
KIWI NG, native + Docker routes, build, testing and troubleshooting); a
commands-only cheat sheet is in
[`BUILDING-QUICKSTART.md`](BUILDING-QUICKSTART.md). In short:

Requires KIWI NG installed on an openSUSE Leap 15.6 (or compatible) host:

```sh
editions/opensuse/scripts/build.sh            # default target dir
editions/opensuse/scripts/build.sh /tmp/livi  # custom target dir
```

The equivalent manual command (note the `--set-repo` — the appliance's primary
repo is `obsrepositories:/`, which only resolves on the Open Build Service, so
local builds supply the Leap 15.6 OSS repo explicitly):

```sh
sudo kiwi-ng system build \
  --description editions/opensuse \
  --set-repo https://download.opensuse.org/distribution/leap/15.6/repo/oss \
  --target-dir builds/opensuse
```

The resulting image is written to the target directory with a `.iso` suffix,
e.g. `livios-opensuse.x86_64-1.0.0.iso`.

The openSUSE **games** repository is declared as a second, `imageonly`
repository (used to satisfy `xgalaga` during the build but not carried into
the running system).

### Testing the ISO

```sh
qemu-system-x86_64 \
  -cdrom builds/opensuse/livios-opensuse.x86_64-1.0.0.iso \
  -m 4096
```

---

## Directory layout

```
editions/opensuse/
├── appliance.kiwi      # KIWI NG image description (schema 7.5)
├── BUILDING.md         # full build walkthrough + troubleshooting
├── BUILDING-QUICKSTART.md  # commands-only build cheat sheet
├── config.sh           # chroot customizations run at end of 'prepare'
├── packages.list       # openSUSE RPM package list (mirrors appliance.kiwi)
├── root/               # filesystem overlay (applied into the image)
│   ├── boot/grub/...           # GRUB theme + splash background
│   ├── etc/default/grub        # openSUSE-flavored GRUB config
│   ├── etc/systemd/system/...  # getty@tty1 autologin override
│   ├── home/demo/...           # LiviOS dotfiles, X session, Openbox theme
│   └── usr/share/plymouth/...  # custom 'livios' plymouth splash theme
└── scripts/build.sh    # convenience build wrapper
```

### What goes where

- **`appliance.kiwi`** — declares the base, repositories, package sets, the
  `demo`/`root` users, and the `iso`/`overlay` image type (with `grub2`
  bootloader and `efi` firmware).
- **`root/`** — the overlay tree. KIWI copies everything under `root/` into the
  image root after packages are installed. This is the openSUSE analog of the
  antiX *file manifest* (see [docs/file-manifest](../../docs/file-manifest/)).
- **`config.sh`** — runs inside the image chroot at the end of the prepare
  step. Selects the plymouth theme, sets the runlevel, fixes `demo` home
  ownership, refreshes fonts, and refreshes the bootloader.
- **`packages.list`** — a human-readable record of the exact RPM package set,
  kept in sync with the `<packages>` sections of `appliance.kiwi`.

### File provenance

The LiviOS payload files live once in `docs/file-manifest/files/`
(dotfiles, Openbox config, banner/guide scripts, splash images, font) and in
`assets/` (the Linudore 64 GRUB theme). The openSUSE `root/` overlay copies
those shared files to their openSUSE destinations and adds openSUSE-specific
files (GRUB config, getty override, `.xinitrc`, plymouth theme) that have no
antiX counterpart.

Mapping (source → overlay destination):

| Shared source | openSUSE destination |
|---|---|
| `files/.bash_profile` | `root/home/demo/.bash_profile` |
| `files/.bashrc` | `root/home/demo/.bashrc` |
| `files/.hushlogin` | `root/home/demo/.hushlogin` |
| `files/.Xresources` | `root/home/demo/.Xresources` |
| `files/.linudore64_banner.sh` | `root/usr/local/bin/` |
| `files/.livios-guide.sh` | `root/usr/local/bin/` |
| `files/autostart` | `root/home/demo/.config/openbox/autostart` |
| `files/rc.xml` | `root/home/demo/.config/openbox/rc.xml` |
| `files/themerc` | `root/home/demo/.themes/liviOS/openbox-3/themerc` |
| `files/JuliaMono-Black.ttf` | `root/home/demo/.fonts/` |
| `files/livios-grub-loading.png` | `root/boot/grub/` |
| `files/livios-splash-planets.png` | `root/usr/share/images/` + plymouth theme |
| `assets/grub/linudore64/` | `root/boot/grub/themes/linudore64/` |

openSUSE-specific overlay files (no shared/antiX source):

| Overlay file | Purpose |
|---|---|
| `etc/default/grub` | openSUSE-flavored GRUB config |
| `etc/systemd/system/getty@tty1.service.d/autologin.conf` | tty1 autologin |
| `home/demo/.xinitrc` | X session → `openbox-session` |
| `usr/share/plymouth/themes/livios/*` | custom boot splash |

---

## How the antiX edition differs (documented for your knowledge)

The antiX edition is built around **runit/sysvinit** (antiX's init), **fim**
(framebuffer image viewer), and **Debian/antiX** conventions. openSUSE uses
**systemd** and **RPM/zypper**, and does not ship several antiX-specific pieces.
Here is exactly how the openSUSE edition reproduces each behavior:

| antiX behavior | antiX mechanism | openSUSE mechanism |
|---|---|---|
| Custom GRUB theme + hidden menu | `/etc/default/grub` (antiX/MX flavor) | `/etc/default/grub` (openSUSE flavor) + `assets/grub/linudore64` theme |
| Boot splash (planet image, 4 s) | runit `/etc/runit/1` runs `fim` | plymouth custom theme `livios` (background image); no `fim` |
| tty1 autologin | runit getty `run` script (`agetty --autologin olivia`) or sysvinit `inittab` | `getty@tty1.service.d/autologin.conf` (`agetty --autologin demo`) |
| Auto-start X on tty1 | `~/.bash_profile` → `exec startx` | `~/.bash_profile` → `exec startx` (same), plus `~/.xinitrc` |
| X session script | `/etc/X11/xinit/xinitrc` → `. /etc/X11/Xsession` (Debian) | `~/.xinitrc` → `exec openbox-session` (openSUSE has no `/etc/X11/Xsession`) |

### Key replaced / dropped files

- **`files/1`** (`/etc/runit/1`) and **`files/run`** (runit getty service) are
  **not** copied. runit does not exist on openSUSE; their roles are taken by
  the plymouth theme and the systemd getty override respectively.
- **`files/grub`** is **not** copied as-is. The antiX version references
  `init-diversity`, `/etc/lsb-release`, and `/etc/default/grub.mx-defaults`,
  none of which exist on openSUSE. A clean openSUSE-flavored file is provided.
- **`files/xinitrc`** (which sources the Debian `/etc/X11/Xsession`) is
  **not** copied to `/etc/X11/xinit/xinitrc`. openSUSE's `startx` reads the
  per-user `~/.xinitrc`, which is provided instead.

### Package / splash viewer change: `fim` → plymouth

The antiX edition uses `fim` (a framebuffer image viewer) to paint the planet
splash. `fim` is **not packaged** in openSUSE's OSS repository, so the openSUSE
edition uses **plymouth** with a custom `livios` theme that renders the same
planet image as a plymouth background. `plymouth`, `plymouth-theme-bgrt`, and
`plymouth-branding-openSUSE` come from OSS; the custom theme lives in the
overlay and is selected in `config.sh`.

### Package / game source change: `xgalaga`

`xgalaga` is not in the main OSS repo; it comes from the openSUSE **games**
repository, which is added as a second `<repository>` in `appliance.kiwi`.

### Release choice: Leap 15.6 (not 16.0)

openSUSE **Leap 16.0** removed the standalone X.org server (only Wayland, with
X11 via XWayland). LiviOS needs a `startx` → Xorg session, so this edition
targets **Leap 15.6**, where the X.org server, `xinit`/`startx`, and the Xorg
drivers are first-class.

---

## Components

- **Custom GRUB theme** — Linudore 64 boot menu
- **Custom plymouth splash** — planet image
- **Openbox environment** — window-decoration-free session
- **C64-themed URxvt terminal** — blue background, light-blue text, JuliaMono
- **Autologin + startx on tty1** — lands directly on the desktop
- **Demo user** (`demo`) with the full LiviOS dotfile set
- **Curated applications** — xgalaga, gcompris-qt (educational)
- **Sound** — ALSA utilities
