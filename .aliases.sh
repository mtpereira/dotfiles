# Shell commands
alias ls="exa -F"
alias l="exa --sort new --long --git --classify --group"
alias la="l -a"
alias cat="bat"
alias less="bat --paging=always"
alias glow="glow --pager"
alias df="df -h"
alias rm="rm -i"

# Shorthands
alias a="ansible"
alias ap="ansible-playbook"
alias ax="ansible-galaxy"
alias d="docker"
alias dc="docker-compose"
alias dm="docker-machine"
alias e="${EDITOR}"
alias g="git"
alias h="http"
alias hk="heroku"
alias k="kubectl"
alias p="packer"
alias s="sudo "
alias t="terraform"
alias ta="tmux attach-session -t"
alias tl="tmux list-sessions"
alias v="vagrant"
alias o="xdg-open"

# Utilities with some sane defaults
alias rdp="xfreerdp /size:80% /scale:180 /kbd:'United Kingdom Extended' -themes -menu-anims +clipboard"
alias swapcaps="setxkbmap -option ctrl:swapcaps"
alias tmux="tmux -2"
alias dmesg="dmesg -T"

# Custom commands
alias d-rm="docker ps -a -q -f status=exited | xargs docker rm -v"
alias d-rmi="docker images -q --filter 'dangling=true' | xargs docker rmi"
alias d-rmv="docker volume ls -qf dangling=true | xargs docker volume rm"
alias d-prune="docker system prune --all --volumes"
alias ducks="du -cms * | sort -rn | head"
alias pproute="ip route | sort -k5 | perl -pe 's/^/$. - /'"
alias ymlinter="python -c 'import yaml,sys;yaml.safe_load(sys.stdin)'"
alias zgen-upgrade="zgen update && zgen reset && source ~/.zshrc"

if [ -d ~/.aliases.d/ ]; then
    for file in ~/.aliases.d/*.sh; do
        [ -r "${file}" ] && source "${file}"
    done
    unset file
fi

