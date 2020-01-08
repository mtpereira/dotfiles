if [ -d ~/.functions.d/ ]; then
    for file in ~/.functions.d/*.sh; do
        [ -r "${file}" ] && source "${file}"
    done
    unset file
fi

### SCRIPTING UTILS ###
function has() {
    return $(which ${1} >/dev/null)
}

function note() {
    echo "[$(tput bold)$(tput setaf 2) INFO $(tput sgr0)] ${*}"
}

function err() {
    echo "[$(tput bold)$(tput setaf 1) ERROR $(tput sgr0)] ${*}"
}

function warn() {
    echo "[$(tput bold)$(tput setaf 3) WARNING $(tput sgr0)] ${*}"
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
    mkdir "${@}" cd "${1}"
}

# mkdir && mv
function mkv() {
    mkdir "${@: 1:1}" && mv -i "${@: 2}" "${@: 1:1}"
}

# cp && EDITOR
function cped () {
    cp -i "${1}" "${2}" && $EDITOR "${2}"
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
  if [ "$(rbenv versions | grep ${ruby_version}); echo $?" = "1" ]; then
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
    bundler \
    debase \
    reek \
    rubocop \
    ruby-debug-ide

  if [ -r ./Gemfile ]; then
    note "Bundelling gems."
    bundle install
  fi
}

function network() {
  read -r -d '' USAGE <<-EOF
    Usage: ${0} NETWORK_NAME [OPTIONS]
    Provide the network name you wish to connect to.

    Options:
    --vpn: Start the openvpn client.
EOF

  if [ $# -lt 1 ]; then
    echo "${USAGE}"
    return 1
  fi

  if [ "${1}" = "-h" ] || [ "${1}" = "--help" ]; then
    echo "${USAGE}"
    return 0
  fi

  local network_name="${1}"
  local vpn=0

  if [ "${2}" != "" ] && [ "${2}" != "--vpn" ]; then
    echo "${USAGE}"
    return 1
  elif [ "${2}" = "--vpn" ]; then
    vpn=1
  fi

  note "Connecting to the ${network_name} network..."
  sudo netctl stop-all \
    && sudo protonvpn disconnect \
    && sudo netctl restart "${network_name}" \
    && sudo systemctl restart systemd-resolved.service

  if [ ${vpn} -eq 1 ]; then
    note "Establishing the VPN connection..."
    sudo PVPN_WAIT=10 protonvpn connect --cc SE
  fi
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

compdef _ruby-setup ruby-setup
function _ruby-setup() {
  _arguments "--no-gemset[do not create a getmset]"
}

compdef _network network
function _network() {
  _arguments "1:network name:($(ls -1 /etc/netctl/))" \
    "--vpn[start the openvpn client]"
}


compdef _headphones headphones
function _headphones() {
  local actions=('connect:connect headphones' 'disconnect: disconnect headphones')
  _describe 'action' actions
}

