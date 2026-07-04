# Architecture

LiviOS is structured around a clear, reproducible architecture that emphasizes transparency and maintainability. Each edition follows the same high‑level model while implementing its own build system and tooling.

## Core Concepts

### Terminal‑First Environment
LiviOS boots directly into a themed Openbox session with a C64‑styled URxvt terminal. The environment is intentionally minimal, fast, and distraction‑free.

### Rootfs Overlay Model
Custom files are stored in `docs/file-manifest/files/` and manually placed into the edition’s root filesystem according to the paths documented in the manifest CSV. This provides predictable placement and supports reproducible builds.

### Branding Pipeline
Branding assets (splash screen, fonts, terminal theme, GRUB theme) are stored in `assets/` and included in the rootfs overlay for the antiX Edition.


### Multi‑Edition Layout
```
editions/
├── antix/
│   ├── rootfs/
│   ├── scripts/
│   └── build-iso.conf
│
└── opensuse/
    ├── kiwi/
    ├── rootfs-overlay/
    └── scripts/
```

### Build Scripts
The antiX Edition uses a set of chroot scripts (`pre-chroot.sh`, `in-chroot.sh`, `post-chroot.sh`) to prepare and finalize the root filesystem.

The openSUSE Edition will use KIWI for image building once development begins.

## Future Architecture Goals
- Unified build pipeline across editions  
- Automated QEMU boot testing  
- Reference image comparison for visual reproducibility  
- openQA integration for the openSUSE Edition
