# Building the LiviOS openSUSE ISO with KIWI NG

This guide walks through producing the `livios-opensuse` live ISO on your own
machine using **KIWI NG** (`kiwi-ng`). It covers two environments:

1. **Native** — install KIWI NG directly on an openSUSE host (`zypper`).
2. **Containerized** — run the build inside an `opensuse/leap` Docker container
   (more isolated and reproducible).

For a condensed, commands-only cheat sheet, see
[`BUILDING-QUICKSTART.md`](BUILDING-QUICKSTART.md).

> **Note on the real build host.** This sandbox has **no root/sudo**, so the
> build cannot be executed here — it must be run on a machine where you have
> `sudo`. If your host is **openSUSE Tumbleweed** (not Leap 15.6), the only
> thing that changes is the *KIWI install* repository name (`<DIST>`). The
> *appliance* itself always targets **Leap 15.6**, so the manual build command
> still points `--set-repo` at the Leap 15.6 OSS repo.

---

## 1. Prerequisites & system requirements

- An **openSUSE** host (Leap 15.6 or Tumbleweed), **x86_64**, with `sudo`.
- Internet access to `download.opensuse.org`.
- A few GB of free disk space (package cache + intermediate image roots).
- **QEMU** (optional but recommended) to test the resulting ISO.

KIWI NG's current release is 10.x and is tested on Leap 15.6+ and Tumbleweed.

---

## 2. Install KIWI NG (native)

### 2.1 Add the OBS builder repository

Replace `<DIST>` with your distribution directory. For **Leap 15.6** that is
`openSUSE_Leap_15.6`; for **Tumbleweed** it is `openSUSE_Tumbleweed`.

```sh
sudo zypper addrepo \
  http://download.opensuse.org/repositories/Virtualization:/Appliances:/Builder/openSUSE_Leap_15.6 \
  kiwi-appliance-builder
sudo zypper --gpg-auto-import-keys refresh
```

> **Tumbleweed host:** substitute
> `http://download.opensuse.org/repositories/Virtualization:/Appliances:/Builder/openSUSE_Tumbleweed`
> as the `<DIST>` directory above.

### 2.2 Install KIWI NG

```sh
sudo zypper --gpg-auto-import-keys install python3-kiwi
```

`python3-kiwi` depends on `kiwi-systemdeps-core`, which brings in the bundle of
tools KIWI needs (zip, dracut, gawk, perl `XML::Writer`, etc.).

### 2.3 Install ISO-specific build dependencies

The appliance produces a **live ISO**, so the host also needs the tools that
assemble and boot the ISO:

```sh
sudo zypper install xorriso syslinux qemu-tools qemu-kvm
```

- `xorriso` — writes the ISO 9660 image (`xorriso`-based `isopack`).
- `syslinux` — provides `isohdpfx.bin` for the BIOS boot sector.
- `qemu-tools` / `qemu-kvm` — only needed later for testing the ISO in a VM.

### 2.4 Verify

```sh
kiwi-ng --version
```

You should see the KIWI NG version, e.g. `10.2.42`.

---

## 3. Containerized (Docker) route

If you prefer not to install anything on the host, run the whole build inside a
Leap 15.6 container. This also makes failures reproducible and keeps the host
clean.

```sh
docker run -it --rm --platform linux/amd64 \
  -v "$PWD:/build" \
  opensuse/leap:15.6
```

Inside the container (**note:** the mount appears at `/build`):

```sh
# 1. Install KIWI NG + deps
zypper addrepo \
  http://download.opensuse.org/repositories/Virtualization:/Appliances:/Builder/openSUSE_Leap_15.6 \
  kiwi
zypper --gpg-auto-import-keys refresh
zypper in -y python3-kiwi xorriso syslinux dosfstools e2fsprogs squashfs
```

Then run the build with the sources mounted at `/build` (see section 4, but set
`--target-dir /build/builds/opensuse` so the ISO lands on the host).

> The `--privileged` flag is required because KIWI uses loop devices when
> creating the image and mounts the chroot. If your Docker setup disallows
> `--privileged`, the native route is the better option.

---

## Pre-build checklist

Before running the build, confirm the edition is in a consistent state:

| Check | What to verify | How |
|---|---|---|
| `appliance.kiwi` XML valid | Well-formed XML, no schema errors | `xmllint --noout editions/opensuse/appliance.kiwi` |
| `config.sh` syntax | No shell syntax errors | `bash -n editions/opensuse/config.sh` |
| `build.sh` syntax | Wrapper script is valid | `bash -n editions/opensuse/scripts/build.sh` |
| `bootloader-theme` | Set to `linudore64` | `grep bootloader-theme editions/opensuse/appliance.kiwi` |
| `rd.kiwi.allow_plymouth` | On kernel cmdline (keeps splash in live initrd) | `grep 'rd.kiwi.allow_plymouth' editions/opensuse/appliance.kiwi` |
| `plymouth-plugin-script` | In the `image` package list | `grep plymouth-plugin-script editions/opensuse/appliance.kiwi` |
| `sudo` + `python311-pyxdg` | In the `image` package list | `grep -E 'sudo\|pyxdg' editions/opensuse/appliance.kiwi` |
| GRUB theme at `usr/share/grub2` path | Theme files under `root/usr/share/grub2/themes/linudore64/` | `ls editions/opensuse/root/usr/share/grub2/themes/linudore64/theme.txt` |
| `plymouthd.conf` | Static daemon config selecting `livios` | `cat editions/opensuse/root/etc/plymouth/plymouthd.conf` |
| `.Xresources` clean | No antiX `# include` lines (they break xrdb) | `grep -c '# include' editions/opensuse/root/home/demo/.Xresources` (expect `0`) |
| `.xinitrc` xrdb merge | Runs `xrdb -merge` before `exec openbox-session` | `grep 'xrdb' editions/opensuse/root/home/demo/.xinitrc` |
| `config.sh` chown | `demo:demo` (not `demo:users`) | `grep 'chown' editions/opensuse/config.sh` |
| Overlay complete | All 28 overlay files present | `find editions/opensuse/root -type f \| wc -l` (expect `28`) |
| Working tree clean | No uncommitted changes | `git status --short` (expect empty) |

---

## 4. Run the build

The appliance's primary `<repository>` is `obsrepositories:/`, which **only
resolves on the Open Build Service**. For local builds you must point KIWI at
the real Leap 15.6 OSS repo with `--set-repo`.

### 4.1 Convenience wrapper

From the repository root, either use the wrapper:

```sh
editions/opensuse/scripts/build.sh builds/opensuse
```

or with a custom target directory and explicit repo:

```sh
OSS_REPO=https://download.opensuse.org/distribution/leap/15.6/repo/oss \
  editions/opensuse/scripts/build.sh /tmp/livi
```

### 4.2 Manual command

```sh
cd <repo-root>
sudo kiwi-ng system build \
  --description editions/opensuse \
  --set-repo https://download.opensuse.org/distribution/leap/15.6/repo/oss \
  --target-dir builds/opensuse
```

What happens, in order:

1. **prepare** — bootstrap phase installs the base packages into a temporary
   chroot, then installs all `<packages>` sections, copies the `root/` overlay
   tree over the image root, and finally runs `config.sh` inside the chroot
   (runlevel 3, plymouth theme selection, bootloader refresh, font cache).
2. **create** — builds the initrd (Dracut, including the `kiwi-live`/overlay
   modules), installs the GRUB2 bootloader, packs the root into a squashfs /
   ext4 filesystem, and assembles the ISO with `xorriso`.

The image is written into the target directory:

```
builds/opensuse/livios-opensuse.x86_64-1.0.0.iso
```

(other artifacts, such as the kernel and initrd, are also produced there).

### 4.3 Watching the log

By default KIWI writes a log to `./build/image-root.log`. To stream progress to
the terminal instead:

```sh
sudo kiwi-ng --logfile stdout system build ...
```

Add `--debug` for extremely verbose output when investigating a failure.

---

## 5. Test the ISO (QEMU)

Boot the ISO in a VM. QEMU with KVM is fastest:

```sh
qemu-system-x86_64 \
  -enable-kvm \
  -cdrom builds/opensuse/livios-opensuse.x86_64-1.0.0.iso \
  -m 4096
```

Expected boot sequence:

- GRUB2 boot menu with the **Linudore 64** theme (2 s timeout).
- Boot splash: the custom **plymouth `livios`** theme with the planet image.
- Landing on **tty1** autologin as user **`demo`**.
- `startx` launches an **Openbox + URxvt** C64-themed desktop.

To confirm the GRUB theme, plymouth splash and LiviOS overlay actually made it
into the ISO **without booting it**, see the "Verifying the build contents"
section of the edition [`README.md`](README.md).

---

## 6. Iterating / rebuilding

- KIWI NG does **not** clear the target directory between builds. If the target
  dir already contains an image it will stop or warn — remove it first:

  ```sh
  rm -rf builds/opensuse
  ```

- Packages are cached under `/var/cache/kiwi`, so rebuilds after changing the
  description are fast (only new/changed files are re-fetched).

- If you change only the overlay (`root/`) or `config.sh`, you generally do not
  need to wipe the package cache — only the target dir.

---

## 7. Troubleshooting

| Symptom | Cause / fix |
|---|---|
| `isohdpfx.bin` / `syslinux` not found during create | Host is missing `syslinux` (and/or `xorriso`). `sudo zypper install syslinux xorriso` |
| `obsrepositories:/` repo fails or is empty | That source only resolves on OBS. Always pass `--set-repo https://download.opensuse.org/distribution/leap/15.6/repo/oss` |
| Build fails partway through | Read the log: `./build/image-root.log`; re-run with `--debug --logfile stdout` to see the failing step |
| `command not found` for a host tool (dracut, xorriso, …) | `kiwi-systemdeps-core`/specific deps not installed on host. Run step 2.2/2.3 |
| Target directory not empty error | `rm -rf builds/opensuse` before rebuilding |
| OpenSUSE *games* repo trouble | The games repo is declared `imageonly`, so it must be reachable during the build but is not carried into the image. If a mirror is down, pass `--ignore-repos-used-for-build` to make it non-fatal (provided `xgalaga-sdl` is otherwise resolvable) |
| Xorg does not start in QEMU (black screen / no tty7) | Add `xorg-x11-driver-video` (or ensure QEMU's `modesetting`/`qxl` driver is present). Check `~demo/.local/share/xorg/Xorg.0.log` (or `/var/log/Xorg.0.log`) for the failing driver |
| plymouth `livios` theme does not render | Verify `/usr/share/plymouth/themes/livios/` exists, `plymouth-plugin-script` is installed (the `script` module the theme needs), `plymouth-set-default-theme livios` ran in `config.sh`, and `rd.kiwi.allow_plymouth` is on the kernel cmdline (KIWI stops plymouth in the initrd by default). Fall back to the `bgrt` theme by editing `/etc/plymouth/plymouthd.conf` |
| GRUB theme missing / plain menu | The theme must live at `/usr/share/grub2/themes/linudore64/` in the overlay (KIWI searches this path) and `<bootloader-theme>linudore64</bootloader-theme>` must be set in `appliance.kiwi`. KIWI copies the theme to the ISO boot area and overwrites `/etc/default/grub` |
| URxvt colors/font not applied | `.Xresources` must not contain Debian/antiX `# include` lines (they break xrdb's cpp preprocessor) and `.xinitrc` must run `xrdb -merge ~/.Xresources` before `openbox-session` |
| `demo` dotfiles owned by root in image | `config.sh` chowns `/home/demo` after the overlay is applied; confirm that step ran (early post-boot errors usually point here) |

---

## 8. Summary of commands

```sh
# install KIWI NG (native)
sudo zypper addrepo \
  http://download.opensuse.org/repositories/Virtualization:/Appliances:/Builder/openSUSE_Leap_15.6 \
  kiwi-appliance-builder
sudo zypper --gpg-auto-import-keys refresh
sudo zypper --gpg-auto-import-keys install python3-kiwi xorriso syslinux qemu-tools qemu-kvm

# build
sudo kiwi-ng system build \
  --description editions/opensuse \
  --set-repo https://download.opensuse.org/distribution/leap/15.6/repo/oss \
  --target-dir builds/opensuse

# test
qemu-system-x86_64 -enable-kvm -cdrom builds/opensuse/livios-opensuse.x86_64-1.0.0.iso -m 4096
```
