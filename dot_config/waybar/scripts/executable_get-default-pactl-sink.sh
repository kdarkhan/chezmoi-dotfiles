#!/bin/sh

pactl --format=json list sinks | jq -cM --unbuffered "map(select(.name == \"$(pactl get-default-sink)\"))[0].properties | {text:(.\"media.name\" // .\"alsa.name\" // .\"node.name\")}"
