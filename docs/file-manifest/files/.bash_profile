if [ "$(tty)" = "/dev/tty1" ]; then
    exec 2>/dev/null
    clear
    
    exec startx >/dev/null 2>&1
fi
