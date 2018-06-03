export ZSH="$HOME/.oh-my-zsh"

DEFAULT_USER="rag"
CASE_SENSITIVE="false"
DISABLE_AUTO_UPDATE="true"
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="false"
HIST_STAMPS="yyyy-mm-dd"

setopt HIST_IGNORE_SPACE

source "${ZSH}/oh-my-zsh.sh"

source "${HOME}/.zgen/zgen.zsh"

if ! zgen saved; then
  zgen oh-my-zsh
  zgen oh-my-zsh plugins/aws
  zgen oh-my-zsh plugins/common-aliases
  zgen oh-my-zsh plugins/docker
  zgen oh-my-zsh plugins/golang
  zgen oh-my-zsh plugins/gpg-agent
  zgen oh-my-zsh plugins/heroku
  zgen oh-my-zsh plugins/kops
  zgen oh-my-zsh plugins/kubectl
  zgen oh-my-zsh plugins/sudo
  zgen oh-my-zsh plugins/tmux
  zgen oh-my-zsh plugins/vagrant

  zgen load denysdovhan/spaceship-prompt spaceship

  zgen save
fi

SPACESHIP_PROMPT_ADD_NEWLINE=false
SPACESHIP_PROMPT_SEPARATE_LINE=false
SPACESHIP_TIME_SHOW=true

# rag: import shell configurations
source ~/.env
source ~/.aliases
source ~/.functions

# rag: setup asdf
source ~/.asdf/asdf.sh
source ~/.asdf/completions/asdf.bash

# rag: set TERM
export TERM=xterm-256color
[ -n "$TMUX" ] && export TERM=screen-256color

# rag: start keychain
eval $(keychain --quiet --quick --eval --agents gpg,ssh ~/.ssh/tyr ~/.ssh/asgard)

# rag: rbenv init
eval "$(rbenv init -)"

