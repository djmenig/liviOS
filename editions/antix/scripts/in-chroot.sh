#!/bin/bash
#
# Script requires manual review and validation.
# Placeholder for antiX build pipeline.
#
#
#
#
#
# in-chroot.sh - Runs INSIDE the antiX build chroot.
#
# Installs LiviOS packages and applies all customizations that
# require running commands (package management, permissions, GRUB).
#
# Context:
#   - build-iso runs this via chroot into the target filesystem
#   - overlay files are already in place
#   - apt is available, system is minimal antiX-core
# ============================================================

set -euo pipefail

echo "[in-chroot] Starting LiviOS in-chroot customization..."

# ------------------------------------------------------------
# 1. Install LiviOS packages from Debian/antiX repos
# ------------------------------------------------------------
# Notes:
#   - openbox: window manager
#   - rxvt-unicode: terminal emulator (URxvt)
#   - fim: framebuffer image viewer (boot splash)
#   - xinit: startx command
#   - xserver-xorg: full X server (pulls video/input drivers)
#   - xserver-xorg-legacy: allows X to be run via startx
#   - x11-xserver-utils: provides xsetroot for desktop background
#   - unclutter: hide mouse cursor
#   - xgalaga: classic arcade game (C64-era feel)
#   - gcompris-qt: educational software suite
#   - alsa-utils: ALSA sound utilities
#   - libasound2-plugins: ALSA PCM plugin support
#   - xfonts-base: X11 bitmap fonts
# ------------------------------------------------------------
echo "[in-chroot] Updating package lists..."
apt-get update

echo "[in-chroot] Installing LiviOS packages..."
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    openbox \
    rxvt-unicode \
    fim \
    xinit \
    xserver-xorg \
    xserver-xorg-legacy \
    x11-xserver-utils \
    unclutter \
    xgalaga \
    gcompris-qt \
    dialog \
    alsa-utils \
    libasound2-plugins \
    xfonts-base

# ------------------------------------------------------------
# 2. Font cache for overlay-placed JuliaMono font
# ------------------------------------------------------------
# JuliaMono-Black.ttf is placed in /home/demo/.fonts/ via overlay.
# The font is not available as a Debian/antiX package, so we
# rely on the overlay copy and regenerate the font cache.
echo "[in-chroot] Updating font cache for JuliaMono..."
fc-cache -fv 2>&1 || echo "[in-chroot] Warning: fc-cache reported issues"

# ------------------------------------------------------------
# 3. ALSA OSS compatibility (snd-pcm-oss kernel module)
# ------------------------------------------------------------
# Loads the PCM-OSS compatibility module at boot so ALSA can
# be used by applications expecting OSS audio (common in
# retro/fast workflows). Persistent via /etc/modules.
echo "[in-chroot] Configuring snd-pcm-oss kernel module..."
echo "snd-pcm-oss" | tee -a /etc/modules

# ------------------------------------------------------------
# 4. Set ownership on demo user files
# ------------------------------------------------------------
# The overlay files are copied as root; chown them to demo
echo "[in-chroot] Setting home directory ownership..."
chown -R demo:demo /home/demo
chmod 755 /home/demo

# ------------------------------------------------------------
# 5. Set file permissions on system files
# ------------------------------------------------------------
echo "[in-chroot] Setting system file permissions..."

# Banner script must be executable
chmod 755 /usr/local/bin/.linudore64_banner.sh

# Guide script must be executable
chmod 755 /usr/local/bin/.livios-guide.sh

# Splash image (readable by all)
if [ -f /usr/share/images/livios-splash-planets.png ]; then
    chmod 644 /usr/share/images/livios-splash-planets.png
fi

# Runit scripts must be executable
chmod 755 /etc/runit/1
chmod 755 /etc/runit/runsvdir/current/getty-tty1/run

# X11 xinitrc
chmod 755 /etc/X11/xinit/xinitrc

# ------------------------------------------------------------
# 6. Configure GRUB
# ------------------------------------------------------------
# /etc/default/grub is already in place from the overlay.
# Run update-grub to generate /boot/grub/grub.cfg with:
#   - LiviOS splash as background
#   - antiX init-diversity support
#   - Quiet boot parameters
echo "[in-chroot] Running update-grub..."
update-grub 2>&1 || echo "[in-chroot] Warning: update-grub reported issues (may be expected in chroot)"

# ------------------------------------------------------------
# 7. Clean up
# ------------------------------------------------------------
echo "[in-chroot] Cleaning apt cache..."
apt-get clean

echo "[in-chroot] LiviOS in-chroot customization complete."
exit 0
