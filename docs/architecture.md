# Architecture

LiviOS antiX Edition is a small, transparent Linux environment built on top of a
minimal antiX‑core installation. Its purpose is personal and educational: to
recreate the simplicity and charm of my first computer (the Commodore 64) so my
daughter can have a similar first‑computer experience — fun, approachable, and
technical enough to learn real computing fundamentals.

The system is intentionally minimal, predictable, and easy to understand end‑to‑end.

---

## Core Concepts

### Terminal‑First Environment
LiviOS boots directly into a themed Openbox session with a C64‑styled URxvt
terminal. The terminal is the primary interface. Openbox provides lightweight
window management while keeping the workflow centered around learning real
computing concepts through the shell. Windowed applications are available, but
the terminal remains the core experience.

### Installer Model (antiX Edition)
The antiX edition is **not** a live ISO. It is a self-contained installer that
runs **after** a minimal antiX‑core system is installed. This keeps the running
system small and avoids the overhead of an image-based distribution, which is
important for the constrained 32‑bit target hardware.

The installer (`editions/antix/install.sh`) is an **automator**: it copies the
LiviOS payload into place and configures the system. It does **not** invent new
customization logic beyond what is already defined in the payload.

### Payload / File Manifest
All LiviOS‑specific files live in `docs/file-manifest/files/` and are kept intact.
Their destination paths inside the installed system are recorded in
`docs/file-manifest/fileLocations_antiX-demo.csv`. The installer reads this map
and copies each file to its destination. This model keeps every LiviOS change
transparent and auditable.

### Package Delivery
Additional software (Openbox, URxvt, X server, fim, etc.) is installed with
`apt-get` at install time, from the curated `editions/antix/packages.list`.

### Init‑Agnostic Boot Configuration
The installer detects the init system at runtime and configures the boot
experience accordingly:

- **runit** — enables the `getty-tty1` autologin service and the `/etc/runit/1`
  fim splash.
- **sysvinit** — sets tty1 `agetty -a demo` autologin in `/etc/inittab` and shows
  the same splash via `/etc/rc.local`.

This lets LiviOS work across antiX‑core installs regardless of which init they use.

---

## Build Flow (regenerating the installer)

The payload is embedded directly into `install.sh` by the
`editions/antix/scripts/make-installer.sh` script, which:
1. validates that every file in the CSV exists in `docs/file-manifest/files/`,
2. packs `files/`, the CSV, and `packages.list` into a tarball,
3. base64‑encodes it and appends it to `install.sh` after a marker line.

The committed `install.sh` is therefore self‑contained and can be copied to any
installed antiX‑core machine without needing the repository present.

---

## Future Architecture Goals
- Validate `install.sh` on real antiX‑core 32‑bit hardware
- openSUSE Edition: expand the initial KIWI‑based live ISO (64‑bit) into an
  OBS‑built, openQA‑tested offering
- Unified tooling and documentation across editions where it makes sense
