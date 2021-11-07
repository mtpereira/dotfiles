#!/bin/bash

mapfile -t sessions < <( tmux list-sessions -F '#S')
prompt='tmux - Attach to session: '
session=$(printf '%s\n' "${sessions[@]}" | dmenu -b -p "${prompt}")
command="alacritty --command tmux attach-session -t ${session}"

if [[ ! "${sessions[@]}" =~ "${session}" ]]; then
  notify-send "tmux session ${session} does not exist!"
  exit 1
fi

nohup ${command} &> /dev/null &

