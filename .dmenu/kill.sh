#!/bin/bash

declare options=("dropbox
zoom
steam")

process_prompt='kill - Select process: '
process=$(echo -e "${options[@]}" | dmenu -b -p "${process_prompt}")
[ "${process}" = "" ] && exit 1
matches=$(pgrep -fl "${process}")
names=$(echo "${matches}" | awk '{printf "%s ", $2}')
confirmation_prompt="kill - Proceed with ${names}?"
confirmation=$(echo -e "y\nn\n9\n" | dmenu -b -p "${confirmation_prompt}")

if [ "${confirmation}" = 'y' ] || [ "${confirmation}" = '9' ]; then
  pids=$(echo "${matches}" | awk '{print $1}')
  if [ "${pids}" != "" ]; then
    signal=$(([ "${confirmation}" = '9' ] && echo '-KILL') || echo '-TERM')
    for pid in ${pids}; do
      kill ${signal} ${pid}
    done
    notify-send "Sent ${signal#-} to ${names}"
  fi
fi

