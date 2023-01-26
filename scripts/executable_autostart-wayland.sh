#!/bin/bash -e

pgrep gammastep || gammastep-indicator &
pgrep mako || systemd-cat --identifier mako mako &
pgrep wl-paste || wl-paste -t text --watch clipman store --no-persist &

swaymsg "output * scale 1.4 bg ~/Pictures/wallpapers/wallpaper.jpg fill"
swaymsg "input 1133:16511:Logitech_G502 scroll_factor 0.55"

if pgrep kanshi
then
    kanshictl reload
else
    systemd-cat --identifier kanshi kanshi &
fi

pgrep swayidle || swayidle \
    timeout 600 'swaylock -c 1F1F28' \
    timeout 570 'swaymsg "output * dpms off"' \
    resume 'swaymsg "output * dpms on"' before-sleep 'playerctl -a pause; swaylock -c 1F1F28' &
