#!/bin/sh

set -ex

# x0f - DisplayPort
# x13 - USB

current_display="$(ddcutil -d 1 getvcp 60 --brief | grep 'VCP 60')"


if [[ "$1" == "toggle" ]]; then
    if [[ "${current_display}" == *"x0f"* ]]; then
      ddcutil -d 1 setvcp 60 x13
    else
      ddcutil -d 1 setvcp 60 x0f
    fi
else
    if [[ "${current_display}" != *"$1"* ]]; then
      ddcutil -d 1 setvcp 60 $1
    fi
fi

