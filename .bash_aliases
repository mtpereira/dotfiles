# Shell commands
alias ls='ls --color=auto -F'
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'
alias grep="grep --color --exclude-dir='.svn' --exclude-dir='.git'"

# Shorthands
alias g="git"
alias aptg="apt-get"
alias aptc="apt-cache"
alias s="sudo "
alias v="vagrant"
alias a="ansible"
alias ap="ansible-playbook"
alias ax="ansible-galaxy"
alias e="${EDITOR}"
alias d="docker"
alias dc="docker-compose"
alias dm="docker-machine"
alias h="heroku"

# Utilities with some sane defaults
alias rdp="xfreerdp -g 1024x640 -k pt --disable-theming --disable-menu-animations -u "
alias rdp-old="exec rdesktop -k pt -g 1024x640 -r disk:$(hostname)='/home/rag/VirtualBox VMs/shared/' -u "
alias swapcaps='xmodmap ~/.Xmodmap'
alias tmux='tmux -2'
alias ejson='ejson --keydir ~/.ejson/keys'
alias minikube-start='minikube start --vm-driver xhyve --insecure-registry localhost:5000'

# Custom commands
alias rbu="rsync -av --exclude VirtualBox\ VMs/ --exclude \"Desktop/\" --exclude \"Dropbox/\" --exclude \"OneDrive/\" --exclude \"Downloads/\" --exclude \".cache/\" --exclude \"*.un~\" --exclude \".local/share\" --exclude \".vagrant.d/\" --exclude MEOCloud --exclude Library --exclude Applications --exclude debug --exclude projs/linkedcare/deploys --exclude Music --exclude Movies --exclude \".gem\" --exclude \".npm\" --exclude \".rbenv\" --exclude \".dotfiles\" --exclude \".docker/machine/\" --exclude \".git\" --exclude \"virtualenv\" --delete --delete-excluded /Users/rag/ bragi.local:/mnt/elements/backups/tyr/home/rag/ | tee >(ssh bragi \"cat - > /mnt/elements/backups/tyr/home-$(date +%Y%m%d).log\")"
alias pproute="ip route | sort -k5 | perl -pe 's/^/$. - /'"
alias dist-upgrade="sudo apt-get update && sudo apt-get dist-upgrade"
alias safe-upgrade="sudo apt-get update && sudo apt-get safe-upgrade"
alias brew-upgrade="brew upgrade --cleanup && brew cleanup -s --force"
alias pip-upgrade="pip install --upgrade pip && pip list --outdated | awk '{ print \$1 }' | xargs pip install --upgrade"
alias pomo-start="thyme -d -r"
alias pomo-stop="thyme -s"
alias ducks="du -cms * | sort -rn | head"
alias yml-validate="python -c 'import yaml,sys;yaml.safe_load(sys.stdin)'"
alias d-rmi="docker images -q --filter 'dangling=true' | xargs docker rmi"
alias d-rm="docker ps -a -q -f status=exited | xargs docker rm -v"
alias d-volumes-rm="docker volume ls -qf dangling=true | xargs docker volume rm"

# Python 2
alias py2="python2"
alias py3="python3"
alias py="py3"

