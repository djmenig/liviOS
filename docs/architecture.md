# Architecture

LiviOS antiX Edition is a small, transparent Linux environment built on antiX‑core.
Its purpose is personal and educational: to recreate the simplicity and charm of my first computer (the Commodore 64) so my daughter can have a similar first‑computer experience — fun, approachable, and technical enough to learn real computing fundamentals.

The system is intentionally minimal, predictable, and easy to understand end‑to‑end.

## Core Concepts

### Terminal‑First Environment
LiviOS boots directly into a themed Openbox session with a C64‑styled URxvt terminal. The terminal is the primary interface. Openbox provides lightweight window management, locked to a terminal window while also giving the ability to run windowed applications. This workflow is centered around learning real computing concepts through the shell, while also providing the ability to play games and run educational applications.

### Rootfs Overlay Model
Custom files are stored in `docs/file-manifest/files/` and manually placed into the edition’s root filesystem according to the paths documented in the manifest CSV. This provides predictable placement and supports reproducible builds.

### Branding Pipeline
Branding assets (splash screen, fonts, terminal theme, GRUB theme) are stored in `assets/` and included in the rootfs overlay for the antiX Edition.


### Multi‑Edition Layout
```
editions/
├── antix/
│   ├── README.md
│   ├── rootfs/
│   ├── scripts/
│   └── build-iso.conf
│
└── opensuse/
    ├── README.md
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
