#!/usr/bin/env zsh

main() {
    declare -i path_width

    local file=$1
    local path_width=$2
    local ZSH_BOOKMARKS=$3

    if [ -d "${file:A}" ]; then
        cd "${file:A}"
    elif [ -f "${file:a}" ]; then
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

    [[ -n "$ZSH_BOOKMARKS" && -f "$ZSH_BOOKMARKS" ]] || ZSH_BOOKMARKS="$HOME/.zshbookmarks"
    if [ -f "$ZSH_BOOKMARKS" ]; then
        source "$ZSH_BOOKMARKS"
    fi

    i="%${path_width}<...<%~%<<"

    path=$(echo ${(%)i})

    echo $path
}
main "$1" "$2" "$3"
