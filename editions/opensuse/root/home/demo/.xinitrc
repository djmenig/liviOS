#!/bin/sh
# LiviOS openSUSE edition - demo user X session (used by startx)
#
# openSUSE is systemd-based and does not use Debian/antiX /etc/X11/Xsession.
# This user xinitrc starts the LiviOS Openbox session. openbox-session runs
# the per-user autostart (~/.config/openbox/autostart) which sets the blue
# background, hides the mouse cursor, and launches the URxvt terminal.

exec openbox-session
