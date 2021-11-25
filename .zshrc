# uncomment for profiling
# uncomment at the end of the file as well
# zmodload zsh/zprof

DEFAULT_USER="rag"
CASE_SENSITIVE="false"
DISABLE_AUTO_UPDATE="true"
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="false"
HIST_STAMPS="yyyy-mm-dd"

setopt HIST_IGNORE_SPACE

source "${HOME}/.zgen/zgen.zsh"

# configure zsh-autosuggestions
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

# disable compinit from zgen
ZGEN_AUTOLOAD_COMPINIT=""

autoload -Uz compinit
if [ $(date +'%j') != $((stat -c '%w' ~/.zcompdump | cut -d' ' -f1) || 0) ]; then
    compinit
  else
    compinit -C
fi

if ! zgen saved; then
  zgen oh-my-zsh
  zgen oh-my-zsh plugins/golang
  zgen oh-my-zsh plugins/gpg-agent
  zgen oh-my-zsh plugins/kubectl

  zgen load mafredri/zsh-async
  zgen load sindresorhus/pure
  zgen load zsh-users/zsh-syntax-highlighting
  zgen load zsh-users/zsh-autosuggestions

  zgen save
fi

# import shell configurations
source ~/.env.sh
source ~/.aliases.sh
source ~/.functions.sh
source ~/.completions.sh

# setup asdf
source ~/.asdf/asdf.sh
source ~/.asdf/completions/asdf.bash

# start keychain
eval $(keychain --quiet --quick --eval --agents gpg,ssh id_rsa asgard ${GPGKEY})

# rag: rbenv init
eval "$(rbenv init -)"

# configure fzf keybindings
source /usr/share/fzf/key-bindings.zsh

# configure broot
source /home/rag/.config/broot/launcher/bash/br

# uncomment for profiling
# uncomment at the top of the file as well
# zprof

