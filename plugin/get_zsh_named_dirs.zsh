#!/usr/bin/env zsh

declare -i path_width

file=$1
path_width=$2
ZSH_BOOKMARKS=$3

if [ -f "$file" ]; then
    cd "$( dirname "${file:A}" )"
fi

if [ -n "$path_width" ]; then
    re='^[0-9]+$'
    if ! [[ $path_width =~ $re ]] ; then
        path_width=40
    fi
else
    path_width=40
fi

[ -n "$ZSH_BOOKMARKS" ] || ZSH_BOOKMARKS="$HOME/.zshbookmarks"
if [ -f "$ZSH_BOOKMARKS" ]; then
    source "$ZSH_BOOKMARKS"
fi

i="%${path_width}<...<%~%<<"

path=$(echo ${(%)i})

echo $path
