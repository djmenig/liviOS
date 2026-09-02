#!/bin/sh
# LiviOS openSUSE edition - demo user X session (used by startx)
#
# openSUSE is systemd-based and does not use Debian/antiX /etc/X11/Xsession.
# This user xinitrc loads the LiviOS X resources (URxvt C64 colors + font) and
# starts the LiviOS Openbox session. openbox-session runs the per-user autostart
# (~/.config/openbox/autostart) which sets the blue background, hides the mouse
# cursor, and launches the URxvt terminal.
#
# NOTE: xrdb is required (shipped via xorg-x11-essentials). startx normally runs
# /etc/X11/xinit/xinitrc where distros merge ~/.Xresources, but since we exec our
# own session here we must do it ourselves.

[ -f "$HOME/.Xresources" ] && xrdb -merge "$HOME/.Xresources"

# Yield the VT from plymouth to X (if plymouth was active during initrd).
# --retain-splash keeps the splash visible until X is ready; plymouth will
# quit automatically once it detects the X server has taken over the VT.
plymouth quit --retain-splash 2>/dev/null

exec openbox-session
