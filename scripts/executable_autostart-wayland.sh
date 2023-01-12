#!/bin/bash -e

pgrep gammastep || gammastep-indicator &
pgrep mako || systemd-cat --identifier mako mako &
pgrep wl-paste || wl-paste -t text --watch clipman store --no-persist &

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