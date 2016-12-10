# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# don't overwrite GNU Midnight Commander's setting of `ignorespace'.
export HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups
# ... or force ignoredups and ignorespace
export HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=100000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

unset color_prompt force_color_prompt

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# rag: enable color support of ls
if [ -x /usr/bin/dircolors ]; then
    eval "`dircolors -b`"
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# rag: expand history but do not execute
shopt -s histverify

# rag: source .bash_functions
if [ -f ~/.bash_functions ]; then
    . ~/.bash_functions
fi

# rag: source .bash_env
if [ -f ~/.bash_env ]; then
    . ~/.bash_env
fi

# rag: start keychain
eval `keychain --quiet --quick --eval --agents ssh,gpg tyr asgard vagrant`

# rag: be more compatible with the rest of the
# world, avoid "terminal is not fully functional"
case "$TERM" in
    rxvt*256color*)
       TERM=rxvt
    ;;
esac

# rag: use powerline-shell (https://github.com/milkbikis/powerline-shell)
function _update_ps1() {
    export PS1="$(~/.dotfiles/powerline-shell/powerline-shell.py --cwd-max-depth 5 --colorize-hostname --mode flat $? 2> /dev/null)"
}
export PROMPT_COMMAND="_update_ps1 && echo -ne \"\033]0;${USER}@${HOSTNAME}\007\""

