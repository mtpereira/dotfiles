#!/bin/bash
#
# *Highly* inspired (ripped-off) from https://github.com/statico/dotfiles
#
# Usage:
#   curl http://github.com/mtpereira/dotfiles/raw/main/install.sh | sh
#
# or:
#
#   ~/.dotfiles/install.sh
#
# (It doesn't descend into directories.)

set -eu

basedir=$HOME/.dotfiles
bindir=$HOME/bin
gitbase=git://github.com/mtpereira/dotfiles.git
tarball=http://github.com/mtpereira/dotfiles/tarball/main

function has() {
    return $(which $1 >/dev/null)
}

function note() {
    echo "$(tput setaf 1)$*$(tput sgr0)"
}

function warn() {
    echo "$(tput setaf 2)$*$(tput sgr0)"
}

function die() {
    warn $*
    exit 1
}

function link() {
    src=$1
    dest=$2

    if [ -e $dest ]; then
        if [ -L $dest ]; then
            # Already symlinked -- I'll assume correctly.
            return
        else
            # Rename files with a ".old" extension.
            warn "$dest file already exists, renaming to $dest.old"
            backup=$dest.old
            if [ -e $backup ]; then
                die "$backup already exists. Aborting."
            fi
            mv -v $dest $backup
        fi
    fi

    # Update existing or create new symlinks.
    ln -vsf $src $dest
}

function unpack_tarball() {
    note "Downloading tarball..."
    mkdir -vp $basedir
    cd $basedir
    tempfile=TEMP.tar.gz
    if has curl; then
        curl -L $tarball >$tempfile
    elif has wget; then
        wget -O $tempfile $tarball
    else:
        die "Can't download tarball."
    fi
    tar --strip-components 1 -zxvf $tempfile
    rm -v $tempfile
}

if [ -e $basedir ]; then
    # Basedir exists. Update it.
    cd $basedir
    if [ -e .git ]; then
        note "Updating dotfiles from git..."
        git pull --rebase origin
    else
        die "$basedir exists but has no .git dir."
    fi
else
    # .dotfiles directory needs to be installed. Try downloading first with
    # git, then use tarballs.
    if has git; then
        note "Cloning from git..."
        git clone $gitbase $basedir
        cd $basedir
        git submodule init
        git submodule update
    else
        die "Git not installed."
    fi
fi

note "Installing dotfiles..."
for path in .* ; do
    case $path in
        .|..|.git|.gitignore|.talismanignore)
            continue
            ;;
        *)
            link $basedir/$path $HOME/$path
            ;;
    esac
done

note "Installing .gitignore..."
if [ -e gitignore ]; then
    link $basedir/gitignore $HOME/.gitignore
fi

note "Symlinking Vim configurations..."
for rc in vim; do
    link $basedir/.vim/${rc}rc $HOME/.${rc}rc
    if [ ! -e $HOME/.${rc}local ]; then
        touch $HOME/.${rc}local
    fi
done

note "Initializing tools..."
if has vim; then
  cd $basedir
  ./.vim/install.sh
fi

if has tmux; then
  if [ ! -d ~/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  fi
fi

if has zsh; then
  if [ ! -d ~/.oh-my-zsh ]; then
    git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
  fi

  if [ ! -d ~/.zgen ]; then
    git clone https://github.com/tarjoilija/zgen.git ~/.zgen
  fi
fi

if has rbenv; then
  mkdir -p "$(rbenv root)/plugins"
  git clone git://github.com/tpope/rbenv-aliases.git \
    "$(rbenv root)/plugins/rbenv-aliases"
  rbenv alias --auto
fi

note "Running post-install script, if any..."
postinstall=$HOME/.postinstall
if [ -e $postinstall ]; then
    # A post-install script can the use functions defined above.
    . $postinstall
fi

note "Done."

