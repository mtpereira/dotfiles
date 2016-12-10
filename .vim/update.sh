#!/bin/bash
#
# *Highly* inspired (ripped-off) from https://github.com/statico/dotfiles
#
# Updates Vim plugins.
#
# Update everything (long):
#
#   ./update.sh
#
# Update just the things from Git:
#
#   ./update.sh repos
#
# Update just one plugin from the list of Git repos:
#
#   ./update.sh repos powerline
#

set -e

cd ~/.dotfiles

vimdir=$HOME/.vim
bundledir=$vimdir/bundle
tmp=/tmp/$LOGNAME-vim-update
me=.vim/update.sh

# URLS --------------------------------------------------------------------

# This is a list of all plugins which are available via Git repos. git:// URLs
# don't work.
repos=(
  https://github.com/Chiel92/vim-autoformat.git
  https://github.com/SirVer/ultisnips.git
  https://github.com/Valloric/YouCompleteMe.git
  https://github.com/Xuyuanp/nerdtree-git-plugin.git
  https://github.com/airblade/vim-gitgutter.git
  https://github.com/altercation/vim-colors-solarized.git
  https://github.com/ctrlpvim/ctrlp.vim.git
  https://github.com/editorconfig/editorconfig-vim.git
  https://github.com/elzr/vim-json.git
  https://github.com/fatih/vim-go.git
  https://github.com/hashivim/vim-terraform.git
  https://github.com/itchyny/lightline.vim.git
  https://github.com/jiangmiao/auto-pairs.git
  https://github.com/scrooloose/nerdtree.git
  https://github.com/scrooloose/syntastic.git
  https://github.com/tomtom/tcomment_vim.git
  https://github.com/tpope/vim-fugitive.git
  https://github.com/tpope/vim-obsession.git
  https://github.com/tpope/vim-pathogen.git
  https://github.com/tpope/vim-sensible.git
  https://github.com/junegunn/vim-easy-align.git
  https://github.com/ekalinin/Dockerfile.vim.git
  )

# Here's a list of everything else to download in the format
# '<destination>;<url>[;<filename>]'
other=(
  )

case "$1" in

  # GIT -----------------------------------------------------------------
  repos)
    mkdir -p $bundledir
    for url in ${repos[@]}; do
      if [ -n "$2" ]; then
        if ! (echo "$url" | grep "$2" &>/dev/null) ; then
          continue
        fi
      fi
      dest="$bundledir/$(basename $url | sed -e 's/\.git$//')"
      rm -rf $dest
      echo "Cloning $url into $dest"
      git clone --recurse-submodules --depth 1 $url $dest
	  if [ "$url" == "https://github.com/Valloric/YouCompleteMe.git" ]; then
		$dest/install.py --clang-completer --gocode-completer
	  fi
      rm -rf $dest/.git
    done
    ;;

  # TARBALLS AND SINGLE FILES -------------------------------------------
  other)
    set -x
    mkdir -p $bundledir
    rm -rf $tmp
    mkdir $tmp
    pushd $tmp

    for pair in ${other[@]}; do
      parts=($(echo $pair | tr ';' '\n'))
      name=${parts[0]}
      url=${parts[1]}
      filename=${parts[2]}
      dest=$bundledir/$name

      rm -rf $dest

      if echo $url | egrep '.zip$'; then
        # Zip archives from VCS tend to have an annoying outer wrapper
        # directory, so unpacking them into their own directory first makes it
        # easy to remove the wrapper.
        f=download.zip
        $curl -L $url >$f
        unzip $f -d $name
        mkdir -p $dest
        mv $name/*/* $dest
        rm -rf $name $f

      else
        # Assume single files. Create the destination directory and download
        # the file there.
        mkdir -p $dest
        pushd $dest
        if [ -n "$filename" ]; then
          $curl -L $url >$filename
        else
          $curl -OL $url
        fi
        popd

      fi

    done

    popd
    rm -rf $tmp
    ;;

  # HELP ----------------------------------------------------------------

  all)
    $me repos
    $me other
    echo
    echo "Update OK"
    ;;

  *)
    set +x
    echo
    echo "Usage: $0 <section> [<filter>]"
    echo "...where section is one of:"
    grep -E '\w\)$' $me | sed -e 's/)//'
    echo
    echo "<filter> can be used with the 'repos' section."
    exit 1

esac
