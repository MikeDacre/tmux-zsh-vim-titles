#!/usr/bin/env zsh
# Set the ZSH component of the title string
# This component is *heavily* inspired by https://github.com/jreese/zsh-titles

# Get formats
[ -n "$zsh_title_fmt" ] || zsh_title_fmt='${cmd}:${path}'
[ -n "$path_width" ]    || path_width=40

# Set titles
function update_title() {
    local cmd
    local path
    # escape '%' in $1, make nonprintables visible
    cmd=${(V)1//\%/\%\%}
    # remove newlines
    cmd=${cmd//$'\n'/}
    path="%${path_width}<...<%~"
    if [ -n "$cmd" ]; then
        TITLE=$(eval echo "${zsh_title_fmt}")
    else
        TITLE=${path}
    fi
    if [[ -n "$TMUX" ]]; then
        print -Pn "\ek${(%)TITLE}\e\\"
        print -Pn "\e]0;${(%)TITLE}\a"
    elif [[ "$TERM" =~ screen* ]]; then
        print -Pn "\ek${(%)TITLE}\e\\"
        print -Pn "\e]0;${(%)TITLE}\a"
    elif [[ "$TERM" =~ xterm* ]]; then
        print -Pn "\e]0;${(%)TITLE}\a"
    elif [[ "$TERM" =~ ^rxvt-unicode.* ]]; then
        printf '\33]2;%s\007' ${(%)TITLE}
    fi
}

# Called just before a command is executed
# Title component will the command and the path
function _zsh_title__preexec() {
    local -a cmd

    # Re-parse the command line
    cmd=(${(z)@})

    # Construct a command that will output the desired job number.
    case $cmd[1] in
        fg)	cmd="${(z)jobtexts[${(Q)cmd[2]:-%+}]}" ;;
        %*)	cmd="${(z)jobtexts[${(Q)cmd[1]:-%+}]}" ;;
    esac

    cmd=${cmd[1]}

    # Escape '\'
    cmd=${cmd//\\/\\\\\\\\}

    update_title "${cmd}"
}

# Called just before the prompt is printed
# Title component will just be the path
function _zsh_title__precmd() {
    update_title
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _zsh_title__precmd
add-zsh-hook preexec _zsh_title__preexec
