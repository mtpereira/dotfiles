#!/bin/zsh

function show-layout() {
  local -r layout_code="$(xset -q | grep 'LED' | awk '{print $10}')"
  local layout_name="??"
  if [ "${layout_code}" = "00000000" ]; then
    layout_name="US"
  elif [ "${layout_code}" = "00001000" ]; then
    layout_name="PT"
  fi
  echo " ${layout_name}"
}

show-layout

