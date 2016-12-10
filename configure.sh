#!/bin/bash

# DEPRECATED!

set error
set unused

die() {
	echo "$0: $1" >&2 
	exit 1
}

[ $(basename $PWD) = ".dotfiles" ] || die "$0: not on .dotfiles directory, exiting." 

IGNORE=".git .svn"
FIGNORE=$(echo $IGNORE | awk 'BEGIN { RS=" "; FS="\n"; } { print "! -name ", $1 }')
FILES=$(find . -xdev -maxdepth 1 ${FIGNORE} ! -executable -type f -printf "%f ")

for file in ${FILES}; do 
	mv "$HOME/$file" "$PWD/$file.safe"
	ln -s "$PWD/$file" "$HOME/$file" && rm "$PWD/$file.safe"
done

