#!/bin/bash

source ~/.functions.sh

mac_address="38:18:4C:3E:95:E8"

command=""
if bluetoothctl info ${mac_address} | grep -q 'Connected: yes'; then
  command="disconnect"
  headphones disconnect
else
  command="connect"
  headphones disconnect; headphones connect
fi

echo "${command} ${mac_address}" | bluetoothctl
notify-send "headphones: ${command}ing..."

