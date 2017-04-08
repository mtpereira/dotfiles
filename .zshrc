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

source $ZSH/oh-my-zsh.sh

# rag: import shell configurations
source ~/.env
source ~/.aliases
source ~/.functions

# rag: set TERM
export TERM=xterm-256color
[ -n "$TMUX" ] && export TERM=screen-256color

# rag: start keychain
eval $(keychain --quiet --quick --eval --agents gpg,ssh ~/.ssh/tyr ~/.ssh/asgard)

# rag: rbenv init
eval "$(rbenv init -)"

