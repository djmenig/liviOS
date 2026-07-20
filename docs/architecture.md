# Architecture

LiviOS antiX Edition is a small, transparent Linux environment built on antiX‑core.
Its purpose is personal and educational: to recreate the simplicity and charm of my
first computer (the Commodore 64) so my daughter can have a similar first‑computer
experience — fun, approachable, and technical enough to learn real computing fundamentals.

The system is intentionally minimal, predictable, and easy to understand end‑to‑end.

---

## Core Concepts

### Terminal‑First Environment
LiviOS boots directly into a themed Openbox session with a C64‑styled URxvt terminal.
The terminal is the primary interface. Openbox provides lightweight window management
while keeping the workflow centered around learning real computing concepts through
the shell. Windowed applications are available, but the terminal remains the core
experience.

### Rootfs Overlay Model
LiviOS uses a simple, explicit overlay model. Custom files are stored in
`docs/file-manifest/files/`, and their destination paths inside the root filesystem
are documented in the manifest CSV. During the build process, these files are placed
into the antiX Edition’s rootfs, providing predictable behavior and supporting
reproducible builds.

This model keeps all LiviOS-specific changes transparent and easy to audit.

### Build Flow
The antiX Edition uses a small set of chroot scripts to prepare and finalize the
root filesystem: `pre-chroot.sh`, `in-chroot.sh`, and `post-chroot.sh`. Each script
performs a clear, minimal step in the build process. The openSUSE Edition will use
KIWI once development begins.

---

## Future Architecture Goals
- Unified build pipeline across editions  
- Automated QEMU boot testing  
- Reference image comparison for visual reproducibility  
- openQA integration for the openSUSE Edition
