#!/usr/bin/env zsh

file=$1
path_width=$2
ZSH_BOOKMARKS=$3

if [ -f "$file" ]; then
    cd "$( dirname "${file:A}" )"
fi

[ -n "$path_width" ] || path_width=40
[ -n "$ZSH_BOOKMARKS" ] || ZSH_BOOKMARKS="$HOME/.zshbookmarks"

if [ -f "$ZSH_BOOKMARKS" ]; then
    source "$ZSH_BOOKMARKS"
fi
i="%${path_width}<...<%~%<<"; echo ${(%)i}
