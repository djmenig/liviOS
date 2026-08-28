# File Manifest

The LiviOS file manifest documents every custom file included in the distribution
and its exact destination inside an installed system. This provides a clear,
reproducible map of all modifications that `install.sh` applies on top of a base
antiX‑core installation.

## Purpose
- Ensure full transparency of all customizations  
- Support reproducible installs  
- Provide a reference for debugging and future editions  
- Maintain a clean separation between upstream files and LiviOS‑specific additions

## Structure
- `fileLocations_antiX-demo.csv` — CSV mapping each custom file (in `files/`) to
  its installed path. This file is the authoritative destination map used by the
  installer.
- `files/` — Contains all custom LiviOS files (Openbox configs, GRUB theme assets,
  runit services, splash screens, fonts, etc.). These files are kept intact and
  embedded into `install.sh` as its payload.

> Note: `livios-grub-loading.png` is the "Linudore 64 LOADING" splash shown as a
> GRUB background, deployed to `/boot/grub/` (matching the `GRUB_BACKGROUND`
> block in the `grub` config). The alternate planets splash
> (`livios-splash-planets.png`) is deployed to `/usr/share/images/`. Like desktop
> wallpapers, these images are alternatives curated alongside the config files —
> all are included in the payload.

## How the installer uses this manifest
`editions/antix/scripts/make-installer.sh` embeds `files/`, the CSV, and
`packages.list` into `editions/antix/install.sh`. At install time, `install.sh`
reads the CSV and copies each file in `files/` to its destination.

## Notes
- The manifest currently covers the antiX Edition.  
- The openSUSE Edition will receive its own manifest once development begins.
