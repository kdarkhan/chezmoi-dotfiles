#!/bin/sh

set -e

echo 'Starting script for toggling default sink'

current_sink=$(pactl get-default-sink)

if [ -z "$current_sink" ]
then
  echo "current_sink is empty, don't know what to do"
  exit 1
else
  echo "current_sink is $current_sink"

  sinks=$(pactl list short sinks)

  new_sink=""
  found=false

  while IFS= read -r line; do

    if [ -z "$new_sink" ]
    then
      new_sink=$(echo $line | tr -s ' ' | cut -d ' ' -f 2)
    fi

    if [[ $found == "true" ]]
    then
      found=false
      new_sink=$(echo $line | tr -s ' ' | cut -d ' ' -f 2)
    fi

    if [[ $line == *$current_sink* ]]
    then
      found=true
    fi


  done <<< "$sinks"

  if [ -z "$new_sink" ]
  then
    echo "Could not find a sync to set, exiting"
    exit 1
  else
    echo "Setting sink to $new_sink"
    pactl set-default-sink $new_sink
  fi
fi
