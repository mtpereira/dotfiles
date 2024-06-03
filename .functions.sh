### SCRIPTING UTILS ###
function has() {
    return $(which ${1} >/dev/null)
}

function note() {
  if [ "${1}" = "--notify" ]; then
    shift 1
    notify-send --urgency low "${*}"
  else
    echo "[$(tput bold)$(tput setaf 2) INFO $(tput sgr0)] ${*}"
  fi
}

function err() {
  if [ "${1}" = "--notify" ]; then
    shift 1
    notify-send --urgency critical "${*}"
  else
    echo "[$(tput bold)$(tput setaf 1) ERROR $(tput sgr0)] ${*}"
  fi
}

function warn() {
  if [ "${1}" = "--notify" ]; then
    shift 1
    notify-send --urgency normal "${*}"
  else
    echo "[$(tput bold)$(tput setaf 3) WARNING $(tput sgr0)] ${*}"
  fi
}

function die() {
    err "${*}"
    return 1
}

function path_add() {
  if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
    PATH="${PATH:+"$PATH:"}$1"
  fi
}

function path_remove() {
  if [[ "$PATH" == *""* ]]; then
    PATH="${PATH//$1:/}"
  fi
}

# tput helper
# Taken from: (http://linuxtidbits.wordpress.com/2008/08/11/output-color-on-bash-scripts/)
function tputcolors() {
    echo -e "$(tput bold) reg  bld  und   tput-command-colors$(tput sgr0)"
    for i in $(seq 1 7); do
      echo " $(tput setaf $i)Text$(tput sgr0) $(tput bold)$(tput setaf $i)Text$(tput sgr0) $(tput sgr 0 1)$(tput setaf $i)Text$(tput sgr0)  \$(tput setaf $i)"
      done
    echo ' Bold            $(tput bold)'
    echo ' Underline       $(tput sgr 0 1)'
    echo ' Reset           $(tput sgr0)'
    echo ""
}

### SHELL FILE OPERATIONS ###
# mkdir && cd
function mkd() {
    mkdir -p "${@}" \
      && cd "${1}"
}

# mkdir && mv
function mkv() {
    mkdir -p "${@: 1:1}" \
      && mv -i "${@: 2}" "${@: 1:1}"
}

# cp && EDITOR
function cped () {
    cp -i "${1}" "${2}" \
      && $EDITOR "${2}"
}

# symlink
function link() {
    src=$1
    dest=$2

    if [ -e "$dest" ]; then
        if [ -L "$dest" ]; then
            # Already symlinked -- I'll assume correctly.
            return
        else
            # Rename files with a ".old" extension.
            warn "$dest file already exists, renaming to $dest.old"
            backup=$dest.old
            if [ -e "$backup" ]; then
                die "$backup already exists. Aborting."
            fi
            mv -v "$dest" "$backup"
        fi
    fi

    # Update existing or create new symlinks.
    ln -vsf "$src" "$dest"
}

# colourful man
function man() {
  env \
    LESS_TERMCAP_mb=$(printf "\e[1;31m") \
    LESS_TERMCAP_md=$(printf "\e[1;31m") \
    LESS_TERMCAP_me=$(printf "\e[0m") \
    LESS_TERMCAP_se=$(printf "\e[0m") \
    LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
    LESS_TERMCAP_ue=$(printf "\e[0m") \
    LESS_TERMCAP_us=$(printf "\e[1;32m") \
    man "$@"
  }

# copy file contents to xclipboard
function copy() {
  /bin/cat "${1}" | xsel
}

### SHELL UTILS ###
# source .bashrc
function resource() {
    source "${HOME}"/.zshrc
}

function network() {
  read -r -d '' USAGE <<-EOF
    Usage: ${0} NETWORK_NAME [OPTIONS]
    Provide the network name you wish to connect to.

    Options:
    --vpn: Start the openvpn client.
    --notify: Send output via notifications.
EOF

  local network_name=""
  local vpn=0
  local notify=""

  if [ $# -lt 1 ]; then
    echo "${USAGE}"
    return 1
  fi

  while [ ! $# -eq 0 ]; do
    case "${1}" in
      --help | -h)
        echo "${USAGE}"
        return 0
        ;;
      --vpn)
        vpn=1
        shift 1
        ;;
      --notify)
        notify="--notify"
        shift 1
        ;;
      --* | -*)
        echo "${USAGE}"
        return 1
        ;;
      *)
        network_name="${1}"
        shift 1
        ;;
    esac
  done

  local proton_service="openvpn-client@protonvpn.service"
  if [ ! -f /etc/netctl/"${network_name}" ]; then
    err "${notify}" "Network \"${network_name}\" not configured!"
    return 1
  fi

  note "${notify}" "Connecting to the ${network_name} network..."
  sudo netctl stop-all \
    && sudo systemctl stop ${proton_service} \
    && sudo netctl restart "${network_name}" \
    && note "${notify}" "Connected to the ${network_name}."

  if [ ${vpn} -eq 1 ]; then
    local proton_output
    local proton_rc

    note "${notify}" "Establishing the VPN connection..."
    sudo systemctl restart ${proton_service}

    local proton_rc=$(systemctl show ${proton_service} | grep 'ExecMainStatus=' | cut -d'=' -f2)
    local proton_retries=0
    while [ ${proton_rc} -ne 0 ]; do
      if [ ${proton_retries} -lt 3 ]; then
        note "${notify}" "Failed to connect to VPN, retrying..."
        proton_retries=$((proton_retries + 1))
        sleep 3
      else
        proton_output=$(journalctl -xeu ${proton_service} | tail -n 3)
        err "${notify}" "Failed to connect to VPN! Check \`systemctl status ${proton_service}\`"
        return 1
      fi
    done
    note "${notify}" "Connected to the VPN."
  fi
}

compdef _network network
function _network() {
  _arguments "1:network name:($(ls -1 /etc/netctl/))" \
    "--vpn[start the openvpn client]" \
    "--notify[send output via notifications]"
}

function headphones() {
  read -r -d '' USAGE <<-EOF
    Manage connection to bluetooth headphones.
    Usage: ${0} ACTION
    ACTION is either "connect" or "disconnect".
EOF

   local -r mac_address="38:18:4C:3E:95:E8"
   local action="${1}"
   if [ "${action}" != "connect" ] && [ "${action}" != "disconnect" ]; then
     echo "${USAGE}"
     return 1
   fi

   read -r -d '' COMMANDS <<EOF
     power on
     ${action} ${mac_address}
EOF

  note "Running the ${action} command..."
  echo "${COMMANDS}" | bluetoothctl
  unset COMMANDS
}

compdef _headphones headphones
function _headphones() {
  local actions=('connect:connect headphones' 'disconnect: disconnect headphones')
  _describe 'action' actions
}

if [ -d ~/.functions.d/ ]; then
    for file in ~/.functions.d/*.sh; do
        [ -r "${file}" ] && source "${file}"
    done
    unset file
fi

