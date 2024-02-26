source $HOME/.functions.sh

export EDITOR="nvim"
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
export GPGKEY=EEB5DC0C
export GPG_TTY=$(tty)
export GOPROXY="direct"
export GOENV_ROOT="$HOME/.goenv"

path_add $HOME/bin
path_add $HOME/bin/scripts
path_add $HOME/.rbenv/bin
path_add $HOME/go/bin
path_add $GOENV_ROOT/bin
path_add $HOME/.cargo/bin

if [ -d ~/.env.d/ ]; then
    for file in ~/.env.d/*.sh; do
        [ -r "${file}" ] && source "${file}"
    done
    unset file
fi

