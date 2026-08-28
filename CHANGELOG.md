# Changelog

This file tracks notable changes, releases, and milestones across LiviOS editions and delivery pipelines.

## [Unreleased]

### Changed
- **Pivot**: the antiX (32-bit) edition no longer builds a live ISO.
  It is now a **post-install installer** (`install.sh`) that runs on top of a
  minimal antiX-core installation.

### Added
- `editions/antix/install.sh` — self-contained automator that copies the LiviOS
  payload into place, installs packages, and configures the boot experience for
  both runit and sysvinit.
- `editions/antix/scripts/make-installer.sh` — regenerates `install.sh` from the
  payload sources.
- `editions/antix/packages.list` — curated apt packages for the antiX edition.

### Removed
- Build-iso pipeline artifacts that no longer apply to the antiX edition:
  `build-iso.conf`, `pre-chroot.sh`, `in-chroot.sh`, `post-chroot.sh`, and the
  duplicate `editions/antix/rootfs` overlay.
- Vendored `build-iso-mx/` tree and `build/` output directory (live-ISO machinery).

### Updated
- Documentation rewritten to reflect the installer (post-install) model.
- File manifest CSV header updated to "Installed path".
