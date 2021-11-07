#!/bin/bash

source ~/.functions.sh

vpn=""
status="$(protonvpn status | grep -E '^Status:' | awk '{print $2}')"

if [ "${status}" = "Disconnected" ]; then
  vpn="--vpn"
fi

network=$(netctl list | grep -E '^\*' | cut -d' ' -f2)
command="network ${vpn} --notify ${network}"

${command}

