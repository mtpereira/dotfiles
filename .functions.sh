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

### SSH ###
# ssh-copy-id and add to ssh config
function ssh-add-host() {
    if [ -n "${1}" ] && [ -n "${2}" ]; then
        ssh-copy-id "${2}@${1}" || return 1
        echo "Host $(echo ${1} | cut -d'.' -f1)" >> ~/.ssh/config
        echo -e "\tHostname ${1}" >> ~/.ssh/config
        echo -e "\tPort 22" >> ~/.ssh/config
        echo -e "\tUser ${2}" >> ~/.ssh/config
        echo "" >> ~/.ssh/config
    else
        echo "ssh-add-host: Usage: ssh-add-host HOST USER"
    fi
}

# select default ssh key and add it to keyring
# usage: ssh-select-key [name]
function ssh-select-key() {
    selected=""
    sshdir="${HOME}/.ssh"
    if [ -z "${1}" ]; then
        selected="$(hostname -s)"
    else
        selected="${1}"
        if [ ! -e "${sshdir}"/"${selected}" ] ||
           [ ! -e "${sshdir}"/"${selected}".pub ]; then
            err "Selected key does not exist: ${selected}"
            return 1
        fi
    fi
    note "Selected key: ${selected}"
    if [ -e "${sshdir}"/id_rsa ] &&
       [ -e "${sshdir}"/id_rsa.pub ] &&
       [ ! -L "${sshdir}"/id_rsa ] &&
       [ ! -L ${sshdir}/id_rsa.pub ]; then
        err "id_rsa files exist and are NOT symlinks!"
        return 1
    else
        rm -f ${sshdir}/id_rsa{,.pub}
    fi
    link ${sshdir}/"${selected}" ${sshdir}/id_rsa
    link ${sshdir}/"${selected}".pub ${sshdir}/id_rsa.pub
    ssh-add
}

### SYSADMIN ###
function ads() {
    ldapsearch -LLL -D ${1} -W "(sAMAccountName=${2})"
}

function aws-system-reboots() {
    aws ec2 describe-instances --filters $(aws ec2 describe-instance-status --include-all-instances --filter Name=event.code,Values=system-reboot | grep -E 'i-[0-9a-z]{8}' -o | tr '\n' ',' | sed 's/^/Name=instance-id,Values=/')
}

function dm-start() {
    if [ "$#" != "1" ]; then
        echo "Usage: $0 machine-name"
        return 1
    fi

    docker-machine start "${1}"
    eval $(docker-machine env "${1}")
}

### Ruby ###

function ruby-setup() {
read -r -d '' USAGE <<-EOF
    Usage: $0 [OPTIONS]
    Provide a Ruby version on either the first parameter or on a '.ruby-version' file.

    Options:
    --no-gemset: Do not create a gemset for this setup.
EOF

  local gemset=1
  if [ "${1}" != "" ] && [ "${1}" != "--no-gemset" ]; then
    echo "${USAGE}"
    return 1
  elif [ "${1}" = "--no-gemset" ]; then
    gemset=0
  fi


  local ruby_version="$(cat ./.ruby-version)"
  if [ "${ruby_version}" = "" ]; then
    note "Defaulting to the latest Ruby version."
    ruby_version="latest"
  fi

  # install latest ruby version if requested
  if [ "${ruby_version}" = "latest" ]; then
    pushd "${HOME}/.rbenv/" >/dev/null
    git pull --quiet
    popd >/dev/null
    ruby_version=$(rbenv install -l | grep -E '^ +([0-9]\.){2}[0-9]$' | tail -n 1 | tr -d ' ')
  fi

  # only install if version is not installed already
  local is_version_installed="$(rbenv versions | grep ${ruby_version}; echo $?)"
  if [ "${is_version_installed}" = "1" ]; then
    note "Installing Ruby version ${ruby_version}..."
    rbenv install "$ruby_version" \
      || die "rbenv failed to install version ${ruby_version}!"
  else
    note "Ruby version ${ruby_version} already installed."
  fi
  rbenv rehash

  if [ ${gemset} -eq 1 ]; then
    note "Creating the gemset..."
    rbenv gemset init
  fi

  note "Installing gems for development..."
  gem install \
    bundler:'~>1' \
    debase \
    reek \
    rubocop \
    ruby-debug-ide \
    solargraph

  if [ -r ./Gemfile ]; then
    note "Bundelling gems."
    bundle install
  fi
}

compdef _ruby-setup ruby-setup
function _ruby-setup() {
  _arguments "--no-gemset[do not create a getmset]"
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

  if [ ! -f /etc/netctl/"${network_name}" ]; then
    err "${notify}" "Network \"${network_name}\" not configured!"
    return 1
  fi

  note "${notify}" "Connecting to the ${network_name} network..."
  sudo netctl stop-all \
    && sudo protonvpn disconnect > /dev/null \
    && sudo netctl restart "${network_name}" \
    && note "${notify}" "Connected to the ${network_name}."

  if [ ${vpn} -eq 1 ]; then
    local proton_output
    local proton_rc

    note "${notify}" "Establishing the VPN connection..."
    proton_output=$(sudo PVPN_WAIT=15 protonvpn connect --cc SE)
    proton_rc=${?}

    if [ ${proton_rc} -ne 0 ]; then
      err "${notify}" "Failed to connect to VPN!"
      echo ${proton_output} | while read line; do
        err "${notify}" "protonvpn: ${line}"
      done
      return 1
    else
      note "${notify}" "Connected to the VPN."
    fi
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

