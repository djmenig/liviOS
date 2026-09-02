#!/bin/bash
#
# config.sh - LiviOS openSUSE edition
#
# Runs inside the image chroot at the end of the KIWI 'prepare' step, after
# all packages have been installed and the root/ overlay tree has been applied.
# This is where image-specific runtime configuration happens (things that
# cannot be expressed as static files in the overlay).
#
# The static LiviOS files (dotfiles, Openbox config, GRUB config, plymouth
# theme, getty autologin override) live in the root/ overlay and are copied
# into the image automatically by KIWI NG.

set -ex

# Source KIWI helper functions and environment
test -f /.kconfig && . /.kconfig
test -f /.profile && . /.profile

# ---------------------------------------------------------------------------
# Boot / runlevel
# ---------------------------------------------------------------------------
# LiviOS starts X via 'startx' from tty1 (no display manager), so the default
# runlevel stays at multi-user (text). Ensure we are not at a graphical-level
# target that would pull in a display manager.
baseSetRunlevel 3

# ---------------------------------------------------------------------------
# demo user
# ---------------------------------------------------------------------------
# The 'demo' user is defined in appliance.kiwi (<users>). Make sure its home
# exists and all LiviOS dotfiles in the overlay are owned by 'demo'. The
# primary group is auto-created by useradd ('demo'), so chown to demo:demo.
if id demo >/dev/null 2>&1 ; then
    chown -R demo:demo /home/demo 2>/dev/null || true
fi

# ---------------------------------------------------------------------------
# Boot splash (plymouth) -> LiviOS theme
# ---------------------------------------------------------------------------
# fim is not packaged in openSUSE, so LiviOS-openSUSE uses plymouth with the
# custom 'livios' theme shipped in the overlay (requires plymouth-plugin-script
# for the 'script' module). The theme is already selected via the static
# /etc/plymouth/plymouthd.conf overlay; plymouth-set-default-theme keeps the
# system (dracut) initrd and config in sync with what plymouthd reads.
if [ -d /usr/share/plymouth/themes/livios ] && \
   command -v plymouth-set-default-theme >/dev/null 2>&1 ; then
    plymouth-set-default-theme livios >/dev/null 2>&1 || true
else
    cat > /etc/plymouth/plymouthd.conf <<'EOF'
[Daemon]
Theme=livios
ShowDelay=0
EOF
fi

# ---------------------------------------------------------------------------
# GRUB
# ---------------------------------------------------------------------------
# The custom Linudore 64 GRUB theme is shipped in the overlay at
# /boot/grub2/themes/linudore64 and selected via <bootloader-theme> in
# appliance.kiwi (KIWI regenerates the live-ISO grub.cfg against it). The
# /etc/default/grub overlay sets the matching theme/background paths.
update-bootloader --refresh 2>/dev/null || true

# ---------------------------------------------------------------------------
# Fonts
# ---------------------------------------------------------------------------
# Refresh the font cache so JuliaMono (dropped in the overlay) is available.
if command -v fc-cache >/dev/null 2>&1 ; then
    fc-cache -f >/dev/null 2>&1 || true
fi

# ---------------------------------------------------------------------------
# Enable the tty1 autologin getty override shipped in the overlay
# ---------------------------------------------------------------------------
systemctl enable getty@tty1.service >/dev/null 2>&1 || true

echo "LiviOS openSUSE edition configured."
