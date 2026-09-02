#!/bin/bash
# LiviOS Guide dialog script
# No shadow, no borders/lines
# Dialog: light background (WHITE) + dark-blue text (BLUE)
# Tuned for your urxvt (dark-blue bg / light-blue fg)
# Layout: centered title | body (commands) | footer (navigation)

# Create a temporary dialogrc tuned for your urxvt:
# Terminal: dark-blue bg + light-blue fg
# Dialog:   light bg (WHITE) + dark-blue text (BLUE)
#
# BLUE + OFF = darker blue (like your $blue)
# BLUE + ON  = brighter blue (like your $BLUE)
DIALOGRC=$(mktemp)
cat > "$DIALOGRC" << 'EOF'
use_shadow = OFF
use_colors = ON

# Outside the dialog (rest of the terminal)
screen_color = (WHITE,BLUE,OFF)

# Main dialog body: dark-blue text on light background
dialog_color = (BLUE,WHITE,OFF)

# Title: dark-blue (bold) on light background
title_color = (BLUE,WHITE,OFF)

# Borders (kept matching even though --no-lines is used)
border_color = (BLUE,WHITE,OFF)
border2_color = (BLUE,WHITE,OFF)

# Buttons
button_active_color = (WHITE,BLUE,ON)
button_inactive_color = (BLUE,WHITE,OFF)
button_key_active_color = (WHITE,BLUE,ON)
button_key_inactive_color = (BLUE,WHITE,OFF)
button_label_active_color = (WHITE,BLUE,ON)
button_label_inactive_color = (BLUE,WHITE,OFF)
EOF

export DIALOGRC

# Three logical sections inside the message:
# 1. (title is handled by --title, centered by dialog)
# 2. Body = command list
# 3. Footer = navigation hint
HELP_TEXT="\Z4
Commands:

clear				Clear the screen
gcompris-qt			Launch GCompris Games
gdash				Launch GDash Game
xgalaga-sdl			Launch XGalaga game
shutdown			Shutdown the system
reboot			Reboot the system
ls				List directory contents
fim 'file'			Load image



Note: Behind the READY. prompt is a full bash shell. It
may look retro, but every standard bash command works 
just like you expect.
\Zn"

# Display the dialog
dialog \
  --no-shadow \
  --colors \
  --no-collapse \
  --title "LiviOS Guide" \
  --hline "Scroll with arrow keys or PgUp/PgDn. Press Enter to exit." \
  --msgbox "$HELP_TEXT" \
  20 60

# Cleanup
rm -f "$DIALOGRC"
unset DIALOGRC
clear
