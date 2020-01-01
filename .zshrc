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
  zgen oh-my-zsh plugins/yarn

  zgen load mafredri/zsh-async
  zgen load sindresorhus/pure
  zgen load zsh-users/zsh-syntax-highlighting
  zgen load zsh-users/zsh-autosuggestions

  zgen save
fi

# rag: import shell configurations
source ~/.env.sh
source ~/.aliases.sh
source ~/.functions.sh

# rag: setup asdf
source ~/.asdf/asdf.sh
source ~/.asdf/completions/asdf.bash

# rag: start keychain
eval $(keychain --quiet --quick --eval --agents gpg,ssh ~/.ssh/id_rsa)

# rag: rbenv init
eval "$(rbenv init -)"

# rag: configure fzf keybindings
source /usr/share/fzf/key-bindings.zsh

# rag: configure zsh-autosuggestions
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

