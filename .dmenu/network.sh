#!/bin/bash

source ~/.functions.sh

mapfile -t networks < <( ls -1 /etc/netctl/ )
prompt='network - Connect to: '
network=$(printf '%s\n' "${networks[@]}" | dmenu -b -p "${prompt}")
vpn="${1}"
if [ "${network}" = "" ]; then
  exit 0
fi
command="network ${vpn} --notify ${network}"

if [[ ! "${networks[@]}" =~ "${network}" ]]; then
  notify-send --urgency error --app-name network "Network \"${network}\" not configured!"
  exit 1
fi

${command}

