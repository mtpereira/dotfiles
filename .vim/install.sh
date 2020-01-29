#!/usr/bin/env bash
# This file lives in ~/.vim/pack/install.sh
# Remember to add executable: chmod +x ~/.vim/pack/install.sh
#
# Create new folder in ~/.vim/pack that contains a start folder and cd into it.
#
# Arguments:
#   package_group, a string folder name to create and change into.
#
# Examples:
#   set_group syntax-highlighting

function set_group () {
  package_group=$1
  path="$HOME/.vim/pack/$package_group/start"
  mkdir -p "$path"
  cd "$path" || exit
}

# Clone or update a git repo in the current directory.
#
# Arguments:
#   repo_url, a URL to the git repo.
#
# Examples:
#   package https://github.com/tpope/vim-endwise.git

function package () {
  repo_url=$1
  expected_repo=$(basename "$repo_url" .git)
  if [ -d "$expected_repo" ]; then
    cd "$expected_repo" || exit
    result=$(git pull --force)
    echo "$expected_repo: $result"
  else
    echo "$expected_repo: Installing..."
    git clone -q "$repo_url"
  fi
}

(
set_group languages
package https://github.com/tpope/vim-rake &
package https://github.com/tpope/vim-bundler &
package https://github.com/tpope/vim-endwise &
package https://github.com/w0rp/ale &
package https://github.com/elzr/vim-json &
package https://github.com/hashivim/vim-terraform &
package https://github.com/fatih/vim-go &
package https://github.com/ekalinin/Dockerfile.vim &
package https://github.com/pangloss/vim-javascript &
package https://github.com/maralla/completor.vim &
package https://github.com/vim-scripts/bash-support.vim &
package https://github.com/google/vim-jsonnet &
wait
) &

(
set_group git
package https://github.com/Xuyuanp/nerdtree-git-plugin &
package https://github.com/airblade/vim-gitgutter &
package https://github.com/tpope/vim-fugitive &
wait
) &

(
set_group themes
package https://github.com/altercation/vim-colors-solarized &
package https://github.com/itchyny/lightline.vim &
wait
) &

(
set_group files
package https://github.com/scrooloose/nerdtree &
package https://github.com/ctrlpvim/ctrlp.vim &
wait
) &

(
set_group utils
package https://github.com/tomtom/tcomment_vim &
package https://github.com/tpope/vim-sensible &
package https://github.com/junegunn/vim-easy-align &
package https://github.com/tpope/vim-obsession &
package https://github.com/jiangmiao/auto-pairs &
package https://github.com/Chiel92/vim-autoformat &
package https://github.com/editorconfig/editorconfig-vim &
package https://github.com/tpope/vim-surround &
wait
) &
wait

