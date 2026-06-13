#!/bin/bash

# Clear the screen to start fresh
clear

# Grab total and available RAM in Megabytes from the kernel
TOTAL_MB=$(free -m | awk '/^Mem:/{print $2}')
AVAIL_MB=$(free -m | awk '/^Mem:/{print $7}')

# Check if total RAM is less than 1GB (1024 MB)
if [ "$TOTAL_MB" -lt 1024 ]; then
    # Display in MB
    TOTAL_DISP="${TOTAL_MB}M"
    AVAIL_DISP="${AVAIL_MB}M"
else
    # Convert to GB and display
    TOTAL_GB=$(awk "BEGIN {printf \"%.1f\", $TOTAL_MB/1024}")
    AVAIL_GB=$(awk "BEGIN {printf \"%.1f\", $AVAIL_MB/1024}")
    TOTAL_DISP="${TOTAL_GB}G"
    AVAIL_DISP="${AVAIL_GB}G"
fi

# Banner strings
LINE1="**** LINUDORE64 liviOS V1 ****"
LINE2="${TOTAL_DISP} RAM SYSTEM  ${AVAIL_DISP} BASIC BYTES FREE"

# Centered text (Defaulting to 80x25 grid)
print_centered() {
    local text="$1"
    local width=80
    local padding=$(( (width - ${#text}) / 2 ))
    if [ "$padding" -lt 0 ]; then padding=0; fi
    printf "%${padding}s%s\n" "" "$text"
}

# Draw the banner
echo ""
print_centered "$LINE1"
echo ""
print_centered "$LINE2"
echo ""
