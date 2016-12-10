export ZSH=$HOME/.oh-my-zsh

ZSH_THEME="agnoster"
DEFAULT_USER="rag"
CASE_SENSITIVE="false"
DISABLE_AUTO_UPDATE="true"
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="false"
HIST_STAMPS="yyyy-mm-dd"

plugins=( \
    aws \
    brew \
    common-aliases \
    python \
    tmux \
    sudo \
    vagrant \
    gpg-agent \
    heroku \
    docker \
    golang \
    kubectl
)

setopt HIST_IGNORE_SPACE

export PATH="/opt/homebrew/sbin:/opt/homebrew/bin:/opt/homebrew/opt/coreutils/libexec/gnubin:/Users/rag/bin:/Users/rag/bin/scripts:/Users/rag/go/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/opt/X11/bin"
# export MANPATH="/usr/local/man:$MANPATH"

source $ZSH/oh-my-zsh.sh

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export EDITOR='vim'

# rag: default gpg key
export GPGKEY=82D3CE73

# rag: set TERM
export TERM=xterm-256color
[ -n "$TMUX" ] && export TERM=screen-256color

# rag: set go path
export GOPATH=$HOME/go

source ~/.bash_aliases
source ~/.bash_functions

# rag: start keychain
eval `keychain --quiet --quick --eval --agents gpg,ssh tyr asgard`

# rag: rbenv init
eval "$(rbenv init -)"

