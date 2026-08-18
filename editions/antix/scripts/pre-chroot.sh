#!/bin/bash
#
# Script requires manual review and validation.
# Placeholder for antiX build pipeline.
#
#
#
#
#
# pre-chroot.sh - Runs on the HOST before the antiX build chroot is created.
#
# Validates that the LiviOS overlay is complete and correct.
# Exits with non-zero if any required file is missing.
#
# Context:
#   - build-iso sources this script before debootstrap runs
#   - $LIVIOS_ROOT must be set (passed from build-iso.conf)
#   - This script runs on the host, NOT inside the chroot
# ============================================================

set -euo pipefail

LIVIOS_ROOT="${LIVIOS_ROOT:?LIVIOS_ROOT not set}"
OVERLAY="${LIVIOS_ROOT}/editions/antix/rootfs"

echo "[pre-chroot] Validating LiviOS overlay at: ${OVERLAY}"

# === Critical overlay files that MUST exist ===

REQUIRED_FILES=(
    # Bootloader
    "${OVERLAY}/etc/default/grub"

    # Runit (init system) - autologin + splash
    "${OVERLAY}/etc/runit/1"
    "${OVERLAY}/etc/runit/runsvdir/current/getty-tty1/run"

    # X11
    "${OVERLAY}/etc/X11/xinit/xinitrc"

    # Demo user shell
    "${OVERLAY}/home/demo/.bash_profile"
    "${OVERLAY}/home/demo/.bashrc"
    "${OVERLAY}/home/demo/.hushlogin"

    # Demo user terminal theme
    "${OVERLAY}/home/demo/.Xresources"

    # Openbox config
    "${OVERLAY}/home/demo/.config/openbox/autostart"
    "${OVERLAY}/home/demo/.config/openbox/rc.xml"

    # Openbox theme
    "${OVERLAY}/home/demo/.themes/liviOS/openbox-3/themerc"

    # C64 banner script
    "${OVERLAY}/usr/local/bin/.linudore64_banner.sh"

    # LiviOS guide script
    "${OVERLAY}/usr/local/bin/.livios-guide.sh"

    # Splash image (used by FIM framebuffer)
    "${OVERLAY}/usr/share/images/livios-splash-planets.png"

    # Font
    "${OVERLAY}/home/demo/.fonts/JuliaMono-Black.ttf"
)

MISSING=0
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "[pre-chroot]  MISSING: ${file}"
        MISSING=1
    fi
done

if [ "$MISSING" -ne 0 ]; then
    echo "[pre-chroot] ERROR: One or more required overlay files are missing."
    exit 1
fi

echo "[pre-chroot] LiviOS overlay validation PASSED (all ${#REQUIRED_FILES[@]} files present)."
exit 0
